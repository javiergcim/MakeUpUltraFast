/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

/* ---------------*/

float edge_detector(
    vec3 c, vec3 up, vec3 down, vec3 left, vec3 right, 
    vec3 ul, vec3 ur, vec3 dl, vec3 dr) 
{
    // --- Parámetros de Control Relativos ---
    const float epsilon = 0.0001; // Para evitar la división por cero
    
    // Umbral relativo: ¿Qué tan fuerte debe ser la diferencia relativa para ser detectada?
    // Un valor de 0.4 significa que la diferencia perpendicular debe ser un 40%
    // mayor que la diferencia paralela.
    const float relative_threshold = 0.4;
    
    // Suavidad: Rango de la transición para el antialiasing del resultado.
    const float smoothness = 0.5;

    // --- Conversión a Luminancia ---
    float l_c = luma(c);
    float l_up = luma(up);
    float l_down = luma(down);
    float l_left = luma(left);
    float l_right = luma(right);
    float l_ul = luma(ul);
    float l_ur = luma(ur);
    float l_dl = luma(dl);
    float l_dr = luma(dr);

    // --- Cálculo de "Linealidad" Relativa ---

    // 1. Línea Horizontal
    float ridgeH = abs(l_c - l_up) / (l_up + epsilon) + abs(l_c - l_down) / (l_down + epsilon);
    float consistencyH = (abs(l_c - l_left) + abs(l_c - l_right)) / (l_c + epsilon);
    float linenessH = ridgeH - consistencyH;

    // 2. Línea Vertical
    float ridgeV = abs(l_c - l_left) / (l_left + epsilon) + abs(l_c - l_right) / (l_right + epsilon);
    float consistencyV = (abs(l_c - l_up) + abs(l_c - l_down)) / (l_c + epsilon);
    float linenessV = ridgeV - consistencyV;

    // 3. Línea Diagonal (Top-Left a Bottom-Right)
    float ridgeD1 = abs(l_c - l_ur) / (l_ur + epsilon) + abs(l_c - l_dl) / (l_dl + epsilon);
    float consistencyD1 = (abs(l_c - l_ul) + abs(l_c - l_dr)) / (l_c + epsilon);
    float linenessD1 = ridgeD1 - consistencyD1;

    // 4. Línea Diagonal (Top-Right a Bottom-Left)
    float ridgeD2 = abs(l_c - l_ul) / (l_ul + epsilon) + abs(l_c - l_dr) / (l_dr + epsilon);
    float consistencyD2 = (abs(l_c - l_ur) + abs(l_c - l_dl)) / (l_c + epsilon);
    float linenessD2 = ridgeD2 - consistencyD2;
    
    // --- Puntuación final y color de salida ---
    
    // Se toma la máxima puntuación de las 4 direcciones (asegurando que no sea negativa).
    float maxLineness = max(0.0, max(linenessH, max(linenessV, max(linenessD1, linenessD2))));

    // `smoothstep` ahora usa los umbrales relativos.
    return smoothstep(relative_threshold, relative_threshold + smoothness, maxLineness);
}

float line_detector(vec3 center, vec3 up, vec3 down, vec3 left, vec3 right, vec3 ul, vec3 ur, vec3 dl, vec3 dr) {
    const float epsilon = 0.0001;

    // Umbral de la fuerza relativa. Por ejemplo, 0.2 significa que una línea
    // debe ser al menos un 20% más brillante u oscura que su entorno para ser considerada.
    // Este valor es ahora mucho más intuitivo y funciona en distintas iluminaciones.
    const float relative_threshold = 0.01;

    // Suavidad de la transición. Controla qué tan rápido el resaltado
    // pasa de 0 a 1 una vez que se supera el umbral.
    const float smoothness = 0.15;

    float c = luma(center);
    float t = luma(up);
    float b = luma(down);
    float l = luma(left);
    float r = luma(right);
    float tl = luma(ul);
    float tr = luma(ur);
    float bl = luma(dl);
    float br = luma(dr);

    // --- Cálculo de "linealidad" relativa para cada dirección ---
    float linenessH = 0.0, linenessV = 0.0, linenessD1 = 0.0, linenessD2 = 0.0;

    // 1. Línea Horizontal
    if ((c > t && c > b) || (c < t && c < b)) {
        float strength = min(abs(c - t) / (t + epsilon), abs(c - b) / (b + epsilon));
        float penalty = (abs(c - l) + abs(c - r)) / (c + epsilon);
        linenessH = strength - penalty;
    }

    // 2. Línea Vertical
    if ((c > l && c > r) || (c < l && c < r)) {
        float strength = min(abs(c - l) / (l + epsilon), abs(c - r) / (r + epsilon));
        float penalty = (abs(c - t) + abs(c - b)) / (c + epsilon);
        linenessV = strength - penalty;
    }

    // 3. Línea Diagonal (\)
    if ((c > tr && c > bl) || (c < tr && c < bl)) {
        float strength = min(abs(c - tr) / (tr + epsilon), abs(c - bl) / (bl + epsilon));
        float penalty = (abs(c - tl) + abs(c - br)) / (c + epsilon);
        linenessD1 = strength - penalty;
    }

    // 4. Línea Diagonal (/)
    if ((c > tl && c > br) || (c < tl && c < br)) {
        float strength = min(abs(c - tl) / (tl + epsilon), abs(c - br) / (br + epsilon));
        float penalty = (abs(c - tr) + abs(c - bl)) / (c + epsilon);
        linenessD2 = strength - penalty;
    }

    // --- Puntuación final y color de salida ---
    
    // Tomamos la máxima puntuación y nos aseguramos de que no sea negativa.
    float maxLineness = max(0.0, max(linenessH, max(linenessV, max(linenessD1, linenessD2))));

    // `smoothstep` usa nuestro umbral relativo para crear una transición suave.
    return smoothstep(relative_threshold, relative_threshold + smoothness, maxLineness);
    // return maxLineness;
}

vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Previous color
        vec3 previous = texture2D(colortex3, texcoord_past).rgb;

        vec3 left = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0)).rgb;
        vec3 right = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0)).rgb;
        vec3 down = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y)).rgb;
        vec3 up = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y)).rgb;
        vec3 ul = texture2D(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y)).rgb;
        vec3 ur = texture2D(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y)).rgb;
        vec3 dl = texture2D(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y)).rgb;
        vec3 dr = texture2D(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y)).rgb;

        vec3 nmin =
            min(current_color, min(left, min(right, min(up, down))));
        vec3 nmax =
            max(current_color, max(left, max(right, max(up, down))));

        float edge = edge_detector(
            current_color,
            up,
            down,
            left,
            right,
            ul,
            ur,
            dl,
            dr
        );

        // Clip
        vec3 center = (nmin + nmax) * 0.5;
        float radio = length(nmax - center);

        vec3 color_vector = previous - center;
        float color_dist = length(color_vector);

        float factor = 1.0;
        if (color_dist > radio) {
            factor = radio / color_dist;
        }
        previous = center + (color_vector * factor);

        return mix(current_color, previous, 0.65 + (edge * 0.30));
        // return mix(current_color, previous, 0.95);

        // return vec3(edge);
    }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Muestra del pasado
        vec4 previous = texture2D(colortex3, texcoord_past);

        vec4 left = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0));
        vec4 right = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0));
        vec4 down = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y));
        vec4 up = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y));
        vec4 ul = texture2D(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y));
        vec4 ur = texture2D(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y));
        vec4 dl = texture2D(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y));
        vec4 dr = texture2D(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y));

        vec4 nmin =
            min(current_color, min(left, min(right, min(up, down))));
        vec4 nmax =
            max(current_color, max(left, max(right, max(up, down))));

        float edge = line_detector(
            current_color.rgb,
            up.rgb,
            down.rgb,
            left.rgb,
            right.rgb,
            ul.rgb,
            ur.rgb,
            dl.rgb,
            dr.rgb
        );

        // Clip
        vec3 center = (nmin.rgb + nmax.rgb) * 0.5;
        float radio = length(nmax.rgb - center);

        vec3 color_vector = previous.rgb - center;
        float color_dist = length(color_vector);

        float factor = 1.0;
        if (color_dist > radio) {
            factor = radio / color_dist;
        }
        previous = vec4(center + (color_vector * factor), previous.a);

        return mix(current_color, previous, 0.75 + (edge * 0.14));
    }
}

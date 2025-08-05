/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

/* ---------------*/

float line_detector(vec3 c, vec3 up, vec3 down, vec3 left, vec3 right, vec3 ul, vec3 ur, vec3 dl, vec3 dr) {
    float l_c = luma(c);
    float l_up = luma(up);
    float l_down = luma(down);
    float l_left = luma(left);
    float l_right = luma(right);
    float l_ul = luma(ul);
    float l_ur = luma(ur);
    float l_dl = luma(dl);
    float l_dr = luma(dr);

    // --- Cálculo de "Linealidad" para cada dirección ---

    // 1. Línea Horizontal
    float ridgeH = abs(l_c - l_up) + abs(l_c - l_down); // Diferencia con vecinos perpendiculares
    float consistencyH = abs(l_c - l_left) + abs(l_c - l_right); // Diferencia con vecinos paralelos
    float linenessH = ridgeH - consistencyH;

    // 2. Línea Vertical
    float ridgeV = abs(l_c - l_left) + abs(l_c - l_right);
    float consistencyV = abs(l_c - l_up) + abs(l_c - l_down);
    float linenessV = ridgeV - consistencyV;

    // 3. Línea Diagonal (Top-Left a Bottom-Right)
    float ridgeD1 = abs(l_c - l_ur) + abs(l_c - l_dl);
    float consistencyD1 = abs(l_c - l_ul) + abs(l_c - l_dr);
    float linenessD1 = ridgeD1 - consistencyD1;

    // 4. Línea Diagonal (Top-Right a Bottom-Left)
    float ridgeD2 = abs(l_c - l_ul) + abs(l_c - l_dr);
    float consistencyD2 = abs(l_c - l_ur) + abs(l_c - l_dl);
    float linenessD2 = ridgeD2 - consistencyD2;
    
    // --- Puntuación final y color de salida ---
    
    // Se toma la máxima puntuación de las 4 direcciones
    float maxLineness = max(linenessH, max(linenessV, max(linenessD1, linenessD2)));

    // `smoothstep` crea una transición suave en lugar de un corte brusco.
    // Los valores 0.1 y 0.3 son umbrales que puedes ajustar para cambiar la sensibilidad del filtro.
    // - El primer valor es donde empieza el resaltado.
    // - El segundo valor es donde el resaltado alcanza su máximo.
    float lineFactor = smoothstep(0.05, 0.5, maxLineness);
    // float lineFactor = clamp(sqrt(maxLineness), 0.0, 1.0);

    return lineFactor;
}

float line_detector_nice(vec3 center, vec3 up, vec3 down, vec3 left, vec3 right, vec3 ul, vec3 ur, vec3 dl, vec3 dr) {
    // Umbral mínimo para que una línea empiece a ser visible.
    // Aumenta este valor para ignorar líneas muy tenues.
    const float threshold = 0.0025;

    // Suavidad de la transición del resaltado. Un valor más alto
    // crea un resultado más suave (anti-aliasing).
    const float smoothness = 0.075;

    float c = luma(center);
    float t = luma(up);
    float b = luma(down);
    float l = luma(left);
    float r = luma(right);
    float tl = luma(ul);
    float tr = luma(ur);
    float bl = luma(dl);
    float br = luma(dr);

     // 1. Línea Horizontal (Cresta/Valle Vertical)
    float ridgeStrengthH = 0.0;
    if ((c > t && c > b) || (c < t && c < b)) {
        ridgeStrengthH = min(abs(c - t), abs(c - b));
    }

    // 2. Línea Vertical (Cresta/Valle Horizontal)
    float ridgeStrengthV = 0.0;
    if ((c > l && c > r) || (c < l && c < r)) {
        ridgeStrengthV = min(abs(c - l), abs(c - r));
    }

    // 3. Línea Diagonal (\) (Cresta/Valle en la anti-diagonal)
    float ridgeStrengthD1 = 0.0;
    if ((c > tr && c > bl) || (c < tr && c < bl)) {
        ridgeStrengthD1 = min(abs(c - tr), abs(c - bl));
    }

    // 4. Línea Diagonal (/) (Cresta/Valle en la diagonal principal)
    float ridgeStrengthD2 = 0.0;
    if ((c > tl && c > br) || (c < tl && c < br)) {
        ridgeStrengthD2 = min(abs(c - tl), abs(c - br));
    }

    // --- Penalización por inconsistencia a lo largo de la línea ---
    // Restamos la diferencia de color a lo largo de la línea.
    // Una línea perfecta tiene una penalización cercana a cero.
    
    float linenessH = ridgeStrengthH - (abs(c-l) + abs(c-r));
    float linenessV = ridgeStrengthV - (abs(c-t) + abs(c-b));
    float linenessD1 = ridgeStrengthD1 - (abs(c-tl) + abs(c-br));
    float linenessD2 = ridgeStrengthD2 - (abs(c-tr) + abs(c-bl));

    // --- Puntuación final y color de salida ---
    
    // Tomamos la máxima puntuación y nos aseguramos de que no sea negativa.
    float maxLineness = max(0.0, max(linenessH, max(linenessV, max(linenessD1, linenessD2))));

    // `smoothstep` crea una transición suave basada en nuestros parámetros.
    return smoothstep(threshold, threshold + smoothness, maxLineness);
}

vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Previous color
        vec3 previous = texture2D(colortex3, texcoord_past).rgb;

        // Apply clamping on the history color.
        // vec3 near_color0 = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0)).rgb;
        // vec3 near_color1 = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0)).rgb;
        // vec3 near_color2 = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y)).rgb;
        // vec3 near_color3 = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y)).rgb;
       
        // vec3 nmin =
        //     min(current_color, min(near_color0, min(near_color1, min(near_color2, near_color3))));
        // vec3 nmax =
        //     max(current_color, max(near_color0, max(near_color1, max(near_color2, near_color3))));



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

        float edge = line_detector_nice(current_color, up, down, left, right, ul, ur, dl, dr);
        
        // Edge detection
        // vec3 edge_color = -near_color0;
        // edge_color -= near_color1;
        // edge_color += current_color * 4.0;
        // edge_color -= near_color2;
        // edge_color -= near_color3;

        // edge_color = edge_color / (current_color * 2.0);
        // float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);  // 1/sqrt(3)
        // edge = smoothstep(0.25, 0.75, edge);

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

        // return mix(current_color, previous, 0.75 + (edge * 0.24));
        // return mix(current_color, previous, 0.8 + (edge * 0.19));

        return vec3(edge);
    }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Muestra del pasado
        vec4 previous = texture2D(colortex3, texcoord_past);

        vec4 near_color0 = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0));
        vec4 near_color1 = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0));
        vec4 near_color2 = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y));
        vec4 near_color3 = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y));

        vec4 nmin =
            min(current_color, min(near_color0, min(near_color1, min(near_color2, near_color3))));
        vec4 nmax =
            max(current_color, max(near_color0, max(near_color1, max(near_color2, near_color3))));  

        // Edge detection
        vec3 edge_color = -near_color0.rgb;
        edge_color -= near_color1.rgb;
        edge_color += current_color.rgb * 4.0;
        edge_color -= near_color2.rgb;
        edge_color -= near_color3.rgb;

        edge_color = edge_color / (current_color.rgb * 2.0);
        float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);  // 1/sqrt(3)
        edge = smoothstep(0.25, 0.75, edge);

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

        return mix(current_color, previous, 0.65 + (edge * 0.34));
    }
}

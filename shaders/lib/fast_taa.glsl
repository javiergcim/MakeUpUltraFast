/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 convex_hull(
    vec3 c, vec3 previous, vec3 up, vec3 down, vec3 left, vec3 right, 
    vec3 ul, vec3 ur, vec3 dl, vec3 dr) {

    // Cálculo de varianza
    vec3 sum = c + up + down + left + right + ul + ur + dl + dr;
    vec3 sum_sq =
        c*c +
        up*up +
        down*down +
        left*left +
        right*right +
        ul*ul +
        ur*ur +
        dl*dl +
        dr*dr;

    vec3 mean = sum * 0.1111111111111111; // 1 / 9
    vec3 variance = abs(sum_sq * 0.1111111111111111 - mean * mean); // Varianza = E[x^2] - E[x]^2

    // 2. Definir el rango de clamping
    vec3 std_dev = sqrt(variance);
    vec3 min_valid = mean - 0.8 * std_dev;
    vec3 max_valid = mean + 0.8 * std_dev;

    // 3. Aplicar el clamping
    return clamp(previous, min_valid, max_valid);
}

float edge_detector(
    vec3 c, vec3 up, vec3 down, vec3 left, vec3 right, 
    vec3 ul, vec3 ur, vec3 dl, vec3 dr) {
    // --- Parámetros de Control Relativos ---
    const float epsilon = 0.0001;
    const float relative_threshold = 0.4;
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

    // --- Optimización: Calcular diferencias de luminancia una sola vez ---
    float d_up = abs(l_c - l_up);
    float d_down = abs(l_c - l_down);
    float d_left = abs(l_c - l_left);
    float d_right = abs(l_c - l_right);
    float d_ul = abs(l_c - l_ul);
    float d_ur = abs(l_c - l_ur);
    float d_dl = abs(l_c - l_dl);
    float d_dr = abs(l_c - l_dr);
    
    // --- Optimización: Pre-calcular el inverso para los cálculos de consistencia ---
    // Esto reemplaza 4 divisiones por 1 división y 4 multiplicaciones.
    float inv_l_c = 1.0 / (l_c + epsilon);

    // --- Cálculo de "Linealidad" Relativa de forma eficiente ---

    // 1. Línea Horizontal
    // ridge_h utiliza las diferencias perpendiculares (arriba, abajo).
    // La consistencia se mide con las diferencias paralelas (izquierda, derecha).
    float ridge_h = d_up / (l_up + epsilon) + d_down / (l_down + epsilon);
    float lineness_h = ridge_h - (d_left + d_right) * inv_l_c;

    // 2. Línea Vertical
    float ridge_v = d_left / (l_left + epsilon) + d_right / (l_right + epsilon);
    float lineness_v = ridge_v - (d_up + d_down) * inv_l_c;

    // 3. Línea Diagonal (Top-Left a Bottom-Right)
    float ridge_d1 = d_ur / (l_ur + epsilon) + d_dl / (l_dl + epsilon);
    float lineness_d1 = ridge_d1 - (d_ul + d_dr) * inv_l_c;

    // 4. Línea Diagonal (Top-Right a Bottom-Left)
    float ridge_d2 = d_ul / (l_ul + epsilon) + d_dr / (l_dr + epsilon);
    float lineness_d2 = ridge_d2 - (d_ur + d_dl) * inv_l_c;
    
    // --- Puntuación final y color de salida (sin cambios) ---
    
    // Se toma la máxima puntuación de las 4 direcciones (asegurando que no sea negativa).
    float max_lineness = max(0.0, max(lineness_h, max(lineness_v, max(lineness_d1, lineness_d2))));

    // `smoothstep` ahora usa los umbrales relativos.
    return smoothstep(relative_threshold, relative_threshold + smoothness, max_lineness);
}

float fast_edge_detector(vec3 current_color, vec3 left, vec3 right, vec3 up, vec3 down) {
    vec3 edge_color = -left;
    edge_color -= right;
    edge_color += current_color * 4.0;
    edge_color -= down;
    edge_color -= up;
    edge_color = edge_color / (current_color * 2.0);
    
    float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);  // 1/sqrt(3)
    return smoothstep(0.25, 0.75, edge);
}

float line_detector(vec3 center, vec3 up, vec3 down, vec3 left, vec3 right, vec3 ul, vec3 ur, vec3 dl, vec3 dr) {
    const float epsilon = 0.0001;
    const float relative_threshold = 0.01;
    const float smoothness = 0.15;

    // --- Conversión a Luminancia ---
    float c = luma(center);
    float t = luma(up);
    float b = luma(down);
    float l = luma(left);
    float r = luma(right);
    float tl = luma(ul);
    float tr = luma(ur);
    float bl = luma(dl);
    float br = luma(dr);

    // --- Optimización: Calcular diferencias una sola vez ---
    // Cada una de estas se usaba dos veces en el código original.
    float d_t = abs(c - t);
    float d_b = abs(c - b);
    float d_l = abs(c - l);
    float d_r = abs(c - r);
    float d_tl = abs(c - tl);
    float d_tr = abs(c - tr);
    float d_bl = abs(c - bl);
    float d_br = abs(c - br);
    
    // --- Optimización: Pre-calcular inverso para reemplazar divisiones ---
    float inv_c = 1.0 / (c + epsilon);

    // --- Cálculo de "linealidad" relativa de forma eficiente ---
    float lineness_h = 0.0, lineness_v = 0.0, lineness_d1 = 0.0, lineness_d2 = 0.0;

    // 1. Línea Horizontal
    // Condición optimizada: comprueba si (c-t) y (c-b) tienen el mismo signo.
    if ((c - t) * (c - b) > 0.0) {
        float strength = min(d_t / (t + epsilon), d_b / (b + epsilon));
        float penalty = (d_l + d_r) * inv_c;
        lineness_h = strength - penalty;
    }

    // 2. Línea Vertical
    if ((c - l) * (c - r) > 0.0) {
        float strength = min(d_l / (l + epsilon), d_r / (r + epsilon));
        float penalty = (d_t + d_b) * inv_c;
        lineness_v = strength - penalty;
    }

    // 3. Línea Diagonal (\)
    if ((c - tr) * (c - bl) > 0.0) {
        float strength = min(d_tr / (tr + epsilon), d_bl / (bl + epsilon));
        float penalty = (d_tl + d_br) * inv_c;
        lineness_d1 = strength - penalty;
    }

    // 4. Línea Diagonal (/)
    if ((c - tl) * (c - br) > 0.0) {
        float strength = min(d_tl / (tl + epsilon), d_br / (br + epsilon));
        float penalty = (d_tr + d_bl) * inv_c;
        lineness_d2 = strength - penalty;
    }

    // --- Puntuación final y color de salida (sin cambios) ---
    float max_lineness = max(0.0, max(lineness_h, max(lineness_v, max(lineness_d1, lineness_d2))));
    
    return smoothstep(relative_threshold, relative_threshold + smoothness, max_lineness);
}

vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Previous color
        vec3 previous = texture2DLod(colortex3, texcoord_past, 0.0).rgb;

        vec3 left = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, 0.0), 0.0).rgb;
        vec3 right = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, 0.0), 0.0).rgb;
        vec3 down = texture2DLod(colortex1, texcoord + vec2(0.0, -pixel_size_y), 0.0).rgb;
        vec3 up = texture2DLod(colortex1, texcoord + vec2(0.0, pixel_size_y), 0.0).rgb;
        vec3 ul = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y), 0.0).rgb;
        vec3 ur = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y), 0.0).rgb;
        vec3 dl = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y), 0.0).rgb;
        vec3 dr = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y), 0.0).rgb;

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

        // float edge = fast_edge_detector(
        //     current_color,
        //     left,
        //     right,
        //     up,
        //     down
        // );

        // Clip 1
        // previous = clamp(previous, nmin, nmax);

        // Clip 2
        // vec3 center = (nmin + nmax) * 0.5;
        // float radio = length(nmax - center);

        // vec3 color_vector = previous - center;
        // float color_dist = length(color_vector);

        // float factor = 1.0;
        // if (color_dist > radio) {
        //     factor = (radio / color_dist);
        // }
        // previous = center + (color_vector * factor);

        // Clip 3
        previous = convex_hull(
            current_color,
            previous,
            up,
            down,
            left,
            right,
            ul,
            ur,
            dl,
            dr
        );

        return mix(current_color, previous, 0.70 + (edge * 0.25));
        // return mix(current_color, previous, 0.70);
        // return vec3(edge);
    }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Muestra del pasado
        vec4 previous = texture2DLod(colortex3, texcoord_past, 0.0);

        vec4 left = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, 0.0), 0.0);
        vec4 right = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, 0.0), 0.0);
        vec4 down = texture2DLod(colortex1, texcoord + vec2(0.0, -pixel_size_y), 0.0);
        vec4 up = texture2DLod(colortex1, texcoord + vec2(0.0, pixel_size_y), 0.0);
        vec4 ul = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y), 0.0);
        vec4 ur = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y), 0.0);
        vec4 dl = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y), 0.0);
        vec4 dr = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y), 0.0);

        // vec4 nmin =
        //     min(current_color, min(left, min(right, min(up, down))));
        // vec4 nmax =
        //     max(current_color, max(left, max(right, max(up, down))));

        float edge = edge_detector(
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

        // Clip 3
        previous.rgb = convex_hull(
            current_color.rgb,
            previous.rgb,
            up.rgb,
            down.rgb,
            left.rgb,
            right.rgb,
            ul.rgb,
            ur.rgb,
            dl.rgb,
            dr.rgb
        );

        return mix(current_color, previous, 0.75 + (edge * 0.20));
    }
}

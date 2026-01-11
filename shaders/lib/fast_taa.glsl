/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec4 convex_hull(
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

    vec3 std_dev = sqrt(variance);
    vec3 min_valid = mean - std_dev;
    vec3 max_valid = mean + std_dev;

    return vec4(clamp(previous, min_valid, max_valid), distance(min_valid, max_valid));
}

// float edge_detector(
//     vec3 c, vec3 up, vec3 down, vec3 left, vec3 right, 
//     vec3 ul, vec3 ur, vec3 dl, vec3 dr) {
//     // --- Parámetros de Control Relativos ---
//     const float epsilon = 0.0001;
//     const float relative_threshold = 0.4;
//     const float smoothness = 0.5;

//     // --- Conversión a Luminancia ---
//     float l_c = luma(c);
//     float l_up = luma(up);
//     float l_down = luma(down);
//     float l_left = luma(left);
//     float l_right = luma(right);
//     float l_ul = luma(ul);
//     float l_ur = luma(ur);
//     float l_dl = luma(dl);
//     float l_dr = luma(dr);

//     // --- Optimización: Calcular diferencias de luminancia una sola vez ---
//     float d_up = abs(l_c - l_up);
//     float d_down = abs(l_c - l_down);
//     float d_left = abs(l_c - l_left);
//     float d_right = abs(l_c - l_right);
//     float d_ul = abs(l_c - l_ul);
//     float d_ur = abs(l_c - l_ur);
//     float d_dl = abs(l_c - l_dl);
//     float d_dr = abs(l_c - l_dr);
    
//     // --- Optimización: Pre-calcular el inverso para los cálculos de consistencia ---
//     // Esto reemplaza 4 divisiones por 1 división y 4 multiplicaciones.
//     float inv_l_c = 1.0 / (l_c + epsilon);

//     // --- Cálculo de "Linealidad" Relativa de forma eficiente ---

//     // 1. Línea Horizontal
//     // ridge_h utiliza las diferencias perpendiculares (arriba, abajo).
//     // La consistencia se mide con las diferencias paralelas (izquierda, derecha).
//     float ridge_h = d_up / (l_up + epsilon) + d_down / (l_down + epsilon);
//     float lineness_h = ridge_h - (d_left + d_right) * inv_l_c;

//     // 2. Línea Vertical
//     float ridge_v = d_left / (l_left + epsilon) + d_right / (l_right + epsilon);
//     float lineness_v = ridge_v - (d_up + d_down) * inv_l_c;

//     // 3. Línea Diagonal (Top-Left a Bottom-Right)
//     float ridge_d1 = d_ur / (l_ur + epsilon) + d_dl / (l_dl + epsilon);
//     float lineness_d1 = ridge_d1 - (d_ul + d_dr) * inv_l_c;

//     // 4. Línea Diagonal (Top-Right a Bottom-Left)
//     float ridge_d2 = d_ul / (l_ul + epsilon) + d_dr / (l_dr + epsilon);
//     float lineness_d2 = ridge_d2 - (d_ur + d_dl) * inv_l_c;
    
//     // --- Puntuación final y color de salida (sin cambios) ---
    
//     // Se toma la máxima puntuación de las 4 direcciones (asegurando que no sea negativa).
//     float max_lineness = max(0.0, max(lineness_h, max(lineness_v, max(lineness_d1, lineness_d2))));

//     // `smoothstep` ahora usa los umbrales relativos.
//     return smoothstep(relative_threshold, relative_threshold + smoothness, max_lineness);
// }

vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Previous color
        vec3 previous = texture2DLod(colortex3, texcoord_past, 0.0).rgb;

        vec3 left = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, 0.0), 0.0).rgb;
        vec3 right = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, 0.0), 0.0).rgb;
        vec3 down = texture2DLod(colortex1, texcoord + vec2(0.0, -pixelSizeY), 0.0).rgb;
        vec3 up = texture2DLod(colortex1, texcoord + vec2(0.0, pixelSizeY), 0.0).rgb;
        vec3 ul = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, pixelSizeY), 0.0).rgb;
        vec3 ur = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, pixelSizeY), 0.0).rgb;
        vec3 dl = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, -pixelSizeY), 0.0).rgb;
        vec3 dr = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, -pixelSizeY), 0.0).rgb;

        vec3 c_max = max(max(max(left, right), down),max(up, max(ul, max(ur, max(dl, max(dr, current_color))))));
	    vec3 c_min = min(min(min(left, right), down),min(up, min(ul, min(ur, min(dl, min(dr, current_color))))));

        // Clip 3
        vec4 previous_cliped = convex_hull(
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

        float ponderation = clamp((distance(c_max, c_min) - previous_cliped.a) / previous_cliped.a, 0.0, 1.0);

        #ifdef MOTION_BLUR
            float velocity = length(texcoord - texcoord_past) * 10.0;
            return mix(current_color, previous_cliped.rgb, clamp(0.99 - velocity - (smoothstep(0.0, 1.0, ponderation) * 0.33), 0.0, 1.0));
        #else
            return mix(current_color, previous_cliped.rgb, 0.99 - (smoothstep(0.0, 1.0, ponderation) * 0.33));
        #endif
        // return mix(current_color, previous_cliped.rgb, 0.01);
    }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    // Verificamos si proyección queda fuera de la pantalla actual
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        // Muestra del pasado
        vec4 previous = texture2DLod(colortex3, texcoord_past, 0.0);

        vec4 left = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, 0.0), 0.0);
        vec4 right = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, 0.0), 0.0);
        vec4 down = texture2DLod(colortex1, texcoord + vec2(0.0, -pixelSizeY), 0.0);
        vec4 up = texture2DLod(colortex1, texcoord + vec2(0.0, pixelSizeY), 0.0);
        vec4 ul = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, pixelSizeY), 0.0);
        vec4 ur = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, pixelSizeY), 0.0);
        vec4 dl = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, -pixelSizeY), 0.0);
        vec4 dr = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, -pixelSizeY), 0.0);

        vec3 c_max = max(max(max(left.rgb, right.rgb), down.rgb),max(up.rgb, max(ul.rgb, max(ur.rgb, max(dl.rgb, max(dr.rgb, current_color.rgb))))));
	    vec3 c_min = min(min(min(left.rgb, right.rgb), down.rgb),min(up.rgb, min(ul.rgb, min(ur.rgb, min(dl.rgb, min(dr.rgb, current_color.rgb))))));

        // Clip 3
        vec4 previous_cliped = convex_hull(
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

        float ponderation = clamp((distance(c_max, c_min) - previous_cliped.a) / previous_cliped.a, 0.0, 1.0);

        #ifdef MOTION_BLUR
            float velocity = length(texcoord - texcoord_past) * 10.0;
            return mix(current_color, vec4(previous_cliped.rgb, previous.a), clamp(0.99 - velocity - (smoothstep(0.0, 1.0, ponderation) * 0.33), 0.0, 1.0));
        #else
            return mix(current_color, vec4(previous_cliped.rgb, previous.a), 0.99 - (smoothstep(0.0, 1.0, ponderation) * 0.33));
        #endif
    }
}

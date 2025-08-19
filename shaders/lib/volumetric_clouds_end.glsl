/* MakeUp - volumetric_clouds_end.glsl
Fast volumetric clouds (for The End) - MakeUp implementation
*/

vec3 get_end_cloud(vec3 view_vector, vec3 block_color, float bright, float dither, vec3 base_pos, int samples) {
    block_color.rgb *= clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * .3 + 1.0;

    #if defined DISTANT_HORIZONS && defined DEFERRED_SHADER
        float d_dh = texture2DLod(dhDepthTex0, gl_FragCoord.xy / vec2(viewWidth, viewHeight), 0.0).r;
        float linear_d_dh = ld_dh(d_dh);
        if (linear_d_dh < 0.9999) {
            return block_color;
        }
    #endif

    if (view_vector.y > 0.0) {  // Vista sobre el horizonte
        float umbral = 0.25;
        vec3 cloud_color = block_color * 1.75;
        vec3 dark_cloud_color = block_color * 0.9;

        float view_y_inv = 1.0 / view_vector.y;

        float plane_distance_inf = (CLOUD_PLANE - base_pos.y) * view_y_inv;
        vec3 intersection_pos = (view_vector * plane_distance_inf) + base_pos;

        float plane_distance_sup = (CLOUD_PLANE_SUP - base_pos.y) * view_y_inv;
        vec3 intersection_pos_sup = (view_vector * plane_distance_sup) + base_pos;

        vec3 increment = (intersection_pos_sup - intersection_pos) / samples;
        float increment_dist = length(increment);

        float dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
        float dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;
        float dist_aux_coeff = (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.075;
        float dist_aux_coeff_blur = dist_aux_coeff * 0.4;
        float opacity_dist = dist_aux_coeff * 2.5 * view_y_inv;

        float cloud_value = 0.0;
        float density = 0.0; // Inicializar
        bool first_contact = true;

        intersection_pos += (increment * dither);

        for (int i = 0; i < samples; i++) {
            float current_value = texture2D(gaux2, (intersection_pos.xz * .0008) + (frameTimeCounter * CLOUD_HI_FACTOR * 3.0)).r;

            #if V_CLOUDS == 2 && CLOUD_VOL_STYLE == 0
                current_value += texture2D(gaux2, (intersection_pos.zx * .0008) + (frameTimeCounter * CLOUD_LOW_FACTOR * 3.0)).r;
                current_value = smoothstep(0.05, 0.95, current_value * 0.5);
            #endif

            current_value = (current_value - umbral) / (1.0 - umbral);

            float surface_inf = CLOUD_PLANE_CENTER - (current_value * dif_inf);
            float surface_sup = CLOUD_PLANE_CENTER + (current_value * dif_sup);

            // --- OPTIMIZACIÓN: Reestructurar la lógica del bucle ---
            float current_opacity = 0.0;
            float cloud_thickness = surface_sup - surface_inf;

            if (intersection_pos.y > surface_inf && intersection_pos.y < surface_sup) {
                // Dentro de la nube
                current_opacity = min(increment_dist, cloud_thickness);
            }
            else if (cloud_thickness > 0.0 && i > 0) {
                // Cerca del borde de la nube (desenfoque)
                float distance_aux = min(abs(intersection_pos.y - surface_inf), abs(intersection_pos.y - surface_sup));
                if (distance_aux < dist_aux_coeff_blur) {
                    // El cálculo original se simplifica a esto, que es más rápido.
                    float blur_factor = 1.0 - (distance_aux / dist_aux_coeff_blur);
                    current_opacity = min(blur_factor * increment_dist, cloud_thickness);
                }
            }
            
            // La lógica de acumulación y primer contacto se gestiona UNA SOLA VEZ.
            if (current_opacity > 0.0) {
                cloud_value += current_opacity;
                if (first_contact) {
                    first_contact = false;
                    density = (surface_sup - intersection_pos.y) / (CLOUD_PLANE_SUP - CLOUD_PLANE);
                }
            }

            intersection_pos += increment;
        }

        cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);
        density = clamp(density, 0.0001, 1.0);

        cloud_color = mix(cloud_color, dark_cloud_color, sqrt(density));
        cloud_color = mix(cloud_color, cloud_color * 2.0, (1.0 - cloud_value) * bright);

        block_color = mix(block_color, cloud_color, cloud_value * clamp((view_vector.y - 0.06) * 5.0, 0.0, 1.0));
        block_color = mix(block_color, vec3(1.0), clamp(bright * .04, 0.0, 1.0));
    }

    return block_color;
}
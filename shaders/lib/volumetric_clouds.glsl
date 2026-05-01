/* MakeUp - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp implementation
*/

vec3 get_cloud(vec3 eyeDirection, vec3 blockColor, float bright, float dither, vec3 base_pos, int samples, float umbral, vec3 cloudColor, vec3 darkCloudColor) {
    #if VOL_LIGHT == 0
        blockColor.rgb *= clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * .3 + 1.0;
    #endif

    #if defined DISTANT_HORIZONS && defined DEFERRED_SHADER
        float d_dh = texture2D(dhDepthTex0, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).r;
        float linear_d_dh = ld_dh(d_dh);
        if (linear_d_dh < 0.9999) {
            return blockColor;
        }
    #endif

    if (eyeDirection.y > 0.0) {  // Over horizon
        float view_y_inv = 1.0 / eyeDirection.y;

        float plane_distance_inf = (CLOUD_PLANE - base_pos.y) * view_y_inv;
        vec3 intersection_pos = (eyeDirection * plane_distance_inf) + base_pos;

        float plane_distance_sup = (CLOUD_PLANE_SUP - base_pos.y) * view_y_inv;
        vec3 intersection_pos_sup = (eyeDirection * plane_distance_sup) + base_pos;

        float dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
        float dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;

        vec3 increment = (intersection_pos_sup - intersection_pos) / samples;

        float increment_dist = length(increment);

        float dist_aux_coeff = (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.075;
        float dist_aux_coeff_blur = dist_aux_coeff * 0.3;
        float opacity_dist = dist_aux_coeff * 2.0 * view_y_inv;

        float cloud_value = 0.0;
        float density = 0.0; // Inicializar
        bool first_contact = true;

        intersection_pos += (increment * dither);

        for (int i = 0; i < samples; i++) {
            float current_value = texture2D(gaux2, (intersection_pos.xz * 0.0002777777777777778) + (frameTimeCounter * CLOUD_HI_FACTOR)).r;

            #if V_CLOUDS == 2 && CLOUD_VOL_STYLE == 0
                current_value += texture2D(gaux2, (intersection_pos.zx * 0.0002777777777777778) + (frameTimeCounter * CLOUD_LOW_FACTOR)).r;
                current_value = smoothstep(0.05, 0.95, current_value * 0.5);
            #endif

            current_value = (current_value - umbral) / (1.0 - umbral);

            float surface_inf = CLOUD_PLANE_CENTER - (current_value * dif_inf);
            float surface_sup = CLOUD_PLANE_CENTER + (current_value * dif_sup);

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
                    float blur_factor = 1.0 - (distance_aux / dist_aux_coeff_blur);
                    current_opacity = min(blur_factor * increment_dist, cloud_thickness);
                }
            }

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

        float att_factor = mix(1.0, 0.75, bright * (1.0 - rainStrength));

        // --- OPTIMIZACIÓN: Reemplazar pow() por aproximaciones con sqrt() ---
        // pow(x, 0.25) es mucho más rápido y visualmente casi idéntico a pow(x, 0.3) o pow(x, 0.4)
        float density_approx = sqrt(sqrt(density)); // x^0.25

        #if CLOUD_VOL_STYLE == 1
            cloudColor = mix(cloudColor * att_factor, darkCloudColor * att_factor, density_approx * 0.85);
        #else
            cloudColor = mix(cloudColor * att_factor, darkCloudColor * att_factor, sqrt(density));
        #endif

        float cloud_value_approx = sqrt(sqrt(cloud_value));
        cloudColor = mix(cloudColor, cloudColor * 13.0, (1.0 - cloud_value_approx) * bright * bright * (1.0 - rainStrength));

        blockColor = mix(blockColor, cloudColor, cloud_value * clamp((eyeDirection.y - 0.06) * 5.0, 0.0, 1.0));
    }

    return blockColor;
}

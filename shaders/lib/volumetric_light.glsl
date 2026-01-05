/* MakeUp - volumetric_clouds.glsl
Volumetric light - MakeUp implementation
*/

#if VOL_LIGHT == 2

    #define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

    vec3 get_volumetric_pos(vec3 shadowPos) {
        shadowPos = mat3(shadowModelView) * shadowPos + shadowModelView[3].xyz;
        shadowPos = diagonal3(shadowProjection) * shadowPos + shadowProjection[3].xyz;
        float distb = length(shadowPos.xy);
        float distortion = distb * SHADOW_DIST + (1.0 - SHADOW_DIST);

        shadowPos.xy /= distortion;
        shadowPos.z *= 0.2;
        
        return shadowPos * 0.5 + 0.5;
    }

    float get_volumetric_light(float dither, float visibleDistance, mat4 modeli_times_projectioni) {
        float light = 0.0;

        float currentDistance;
        vec3 viewPos;
        vec4 pos;
        vec3 shadowPos;

        for (int i = 0; i < GODRAY_STEPS; i++) {
            // Exponentialy spaced shadow samples
            currentDistance = exp2(i + dither) - 0.6;
            if (currentDistance > visibleDistance) {
                break;
            }

            // Distance to depth
            currentDistance = (far * (currentDistance - near)) / (currentDistance * (far - near));

            viewPos = vec3(texcoord, currentDistance);

            // Clip to world
            pos = modeli_times_projectioni * (vec4(viewPos, 1.0) * 2.0 - 1.0);
            viewPos = (pos.xyz /= pos.w).xyz;

            shadowPos = get_volumetric_pos(viewPos);
            light += shadow2D(shadowtex1, shadowPos).r;
        }

        light /= GODRAY_STEPS;

        return light * light;
    }

    #if defined COLORED_SHADOW

        vec3 get_volumetric_color_light(float dither, float visibleDistance, mat4 modeli_times_projectioni) {
            float light = 0.0;

            float currentDistance;
            vec3 viewPos;
            vec4 pos;
            vec3 shadowPos;

            float shadow_detector = 1.0;
            float shadow_black = 1.0;
            vec4 shadowColor = vec4(1.0);

            float alpha_complement;

            for (int i = 0; i < GODRAY_STEPS; i++) {
                // Exponentialy spaced shadow samples
                currentDistance = exp2(i + dither) - 0.6;
                if (currentDistance > visibleDistance) {
                    break;
                }

                // Distance to depth
                currentDistance = (far * (currentDistance - near)) / (currentDistance * (far - near));

                viewPos = vec3(texcoord, currentDistance);

                // Clip to world
                pos = modeli_times_projectioni * (vec4(viewPos, 1.0) * 2.0 - 1.0);
                viewPos = (pos.xyz /= pos.w).xyz;
                shadowPos = get_volumetric_pos(viewPos);
                
                light += shadow2D(shadowtex0, shadowPos).r;
            }

            light /= GODRAY_STEPS;

            return vec3(light);
        }
        
    #endif

#elif VOL_LIGHT == 1

    float ssGodrays(float dither) {
        float light = 0.0;
        float comp = 1.0 - (near / (far * far));

        vec2 ray_step = vec2(lightpos - texcoord) * 0.2;
        vec2 dither2d = texcoord + (ray_step * dither);

        float depth;

        for (int i = 0; i < CHEAP_GODRAY_SAMPLES; i++) {
            depth = texture2D(depthtex1, dither2d).x;
            dither2d += ray_step;
            light += step(comp, depth);
        }

        return light / CHEAP_GODRAY_SAMPLES;
  }

#endif

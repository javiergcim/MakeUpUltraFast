/* MakeUp - water_dh.glsl
Water reflection and refraction related functions (dh).
*/

#if SUN_REFLECTION == 1
    #if !defined NETHER && !defined THE_END
        float sun_reflection(vec3 fragpos) {
        vec3 astro_pos = worldTime > 12900 ? moonPosition : sunPosition;
        float astro_vector =
            max(dot(normalize(fragpos), normalize(astro_pos)), 0.0);

        return smoothstep(0.995, 1.0, astro_vector) *
            clamp(lmcoord.y, 0.0, 1.0) *
            (1.0 - rainStrength) * 3.0;
        }

    #endif
#endif

vec3 normal_waves_dh(vec3 pos) {
    vec2 wave_2 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.03125) - (frameTimeCounter * .025)).rg;
    wave_2 = wave_2 - .5;
    vec2 partial_wave = wave_2;
    vec3 final_wave = vec3(partial_wave, WATER_TURBULENCE);

    return normalize(final_wave);
}

vec3 refraction(vec3 fragpos, vec3 color, vec3 refraction) {
    vec2 pos = gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y);

    #if REFRACTION == 1
        pos = pos + refraction.xy * (0.075 / (1.0 + length(fragpos) * 0.4));
    #endif

    float water_absortion;
    if (isEyeInWater == 0) {
        float water_distance =
            2.0 * dhNearPlane * dhFarPlane / (dhFarPlane + dhNearPlane - (2.0 * gl_FragCoord.z - 1.0) * (dhFarPlane - dhNearPlane));

        float earth_distance = texture2D(dhDepthTex1, pos.xy).r;
        earth_distance =
            2.0 * dhNearPlane * dhFarPlane / (dhFarPlane + dhNearPlane - (2.0 * earth_distance - 1.0) * (dhFarPlane - dhNearPlane));

        water_absortion = (earth_distance - water_distance) * 0.5;
        water_absortion *= water_absortion;
        water_absortion = (1.0 / -((water_absortion * WATER_ABSORPTION) + 1.125)) + 1.0;
    } else {
        water_absortion = 0.0;
    }

    return mix(texture2D(gaux1, pos.xy).rgb, color, water_absortion);
}

vec3 get_normals(vec3 bump, vec3 fragpos) {
    float NdotE = abs(dot(water_normal, normalize(fragpos)));

    bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

    mat3 tbn_matrix = mat3(
        tangent.x, binormal.x, water_normal.x,
        tangent.y, binormal.y, water_normal.y,
        tangent.z, binormal.z, water_normal.z
    );

    return normalize(bump * tbn_matrix);
}

vec4 reflection_calc_dh(vec3 fragpos, vec3 normal, vec3 reflected, vec3 infinite_color, float dither) {
    vec3 pos = camera_to_screen(fragpos + reflected * 768.0);

    float border =
        clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

    border = clamp(border - pow(pos.y, 10.0), 0.0, 1.0);

    pos.x = abs(pos.x);
    if (pos.x > 1.0) {
        pos.x = 1.0 - (pos.x - 1.0);
    }

    vec4 final_reflex;
    if (texture2D(depthtex0, pos.xy).r < 0.999) {
        final_reflex = vec4(infinite_color, border);
    } else {
        final_reflex = vec4(texture2D(gaux1, pos.xy).rgb, border);
    }
    return final_reflex;
}

vec3 water_shader_dh(
    vec3 fragpos,
    vec3 normal,
    vec3 color,
    vec3 sky_reflect,
    vec3 reflected,
    float fresnel,
    float visible_sky,
    float dither,
    vec3 light_color
) {
    vec4 reflection = vec4(0.0);
    float infinite = 1.0;

    #if REFLECTION == 1
        reflection =
            reflection_calc_dh(fragpos, normal, reflected, sky_reflect, dither);
    #endif

    reflection.rgb = mix(
        sky_reflect * visible_sky,
        reflection.rgb,
        reflection.a
    );

    #ifdef VANILLA_WATER
        fresnel *= 0.8;
    #endif

    #if SUN_REFLECTION == 1
        #ifndef NETHER
            #ifndef THE_END
                return mix(color, reflection.rgb, fresnel * REFLEX_INDEX) +
                    vec3(sun_reflection(reflect(normalize(fragpos), normal))) * light_color * infinite * visible_sky;          
            #else
                return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
            #endif
        #else
            return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
        #endif
    #else
        return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
    #endif
}

#if defined THE_END
    float material_gloss(vec3 reflectedVector, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal) {
        vec3 astroLightPos = (gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
        float astroAlignment =
            max(dot(normalize(reflectedVector), normalize(astroLightPos)), 0.0) * step(0.0001, dot(astroLightPos, flat_normal));

        return clamp(
            mix(0.0, 1.0, pow(clamp(astroAlignment * 2.0 - 1.0, 0.0, 1.0), gloss_power)),
            0.0,
            1.0
        );
    }
#else
    float material_gloss(vec3 reflectedVector, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal) {
        vec3 astroLightPos = mix(-sunPosition, sunPosition, dayNightMix);
        float astroAlignment =
            max(dot(normalize(reflectedVector), normalize(astroLightPos)), 0.0) *
        step(0.0001, dot(astroLightPos, flat_normal));

        return clamp(
            mix(0.0, 1.0, pow(clamp(astroAlignment * 2.0 - 1.0, 0.0, 1.0), gloss_power)) *
            clamp(lmcoord_alt.y, 0.0, 1.0) *
            (1.0 - rainStrength),
            0.0,
            1.0
        ) * abs(mix(1.0, -1.0, dayNightMix));
    }
#endif
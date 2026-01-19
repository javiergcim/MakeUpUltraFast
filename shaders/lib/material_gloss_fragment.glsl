#if defined THE_END
    float materialGloss(vec3 reflectedVector, vec2 lmcoordAlt, float glossPower, vec3 flatNormal) {
        vec3 astroLightPos = (gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
        float astroAlignment =
            max(dot(normalize(reflectedVector), normalize(astroLightPos)), 0.0) * step(0.0001, dot(astroLightPos, flatNormal));

        return clamp(
            mix(0.0, 1.0, pow(clamp(astroAlignment * 2.0 - 1.0, 0.0, 1.0), glossPower)),
            0.0,
            1.0
        );
    }
#else
    float materialGloss(vec3 reflectedVector, vec2 lmcoordAlt, float glossPower, vec3 flatNormal) {
        vec3 astroLightPos = mix(-sunPosition, sunPosition, dayNightMix);
        float astroAlignment =
            max(dot(normalize(reflectedVector), normalize(astroLightPos)), 0.0) *
        step(0.0001, dot(astroLightPos, flatNormal));

        return clamp(
            mix(0.0, 1.0, pow(clamp(astroAlignment * 2.0 - 1.0, 0.0, 1.0), glossPower)) *
            clamp(lmcoordAlt.y, 0.0, 1.0) *
            (1.0 - rainStrength),
            0.0,
            1.0
        ) * abs(mix(1.0, -1.0, dayNightMix));
    }
#endif
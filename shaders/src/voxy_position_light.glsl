// -- Position Vertex

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float fogDensityCoeff = FOG_DENSITY * FOG_ADJUST;
    #else
        float fogDensityCoeff = dayBlendFloatVoxy(
            FOG_SUNSET,
            FOG_DAY,
            FOG_NIGHT,
            dayMixerV,
            nightMixerV,
            dayMomentV
        ) * FOG_ADJUST;
    #endif

    // ---- Original Light Vertex Logic

    // Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
    #if defined THE_END || defined NETHER
        vec2 illumination = vec2(lmcoord.x, 1.0);
    #else
        vec2 illumination = lmcoord;
    #endif

    illumination.y *= 1.06951871657754;
    float visibleSky = clamp(illumination.y, 0.0, 1.0);

    #if defined UNKNOWN_DIM
        visibleSky = (visibleSky * 0.6) + 0.4;
    #endif

    // Intensidad y color de luz de candelas
    float candle_luma = illumination.x * sqrt(illumination.x);
    vec3 candleColor = CANDLE_BASELIGHT * (candle_luma + sixthPow(illumination.x * 1.17));
    candleColor = clamp(candleColor, vec3(0.0), vec3(4.0));

    // Atenuación por dirección de luz directa ===================================
    #if defined THE_END || defined NETHER
        vec3 astroVector = normalize(vxModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
    #else
        vec3 astroVector = normalize(sunPosition);
    #endif

    vec3 normal = vec3(uint((face>>1)==2), uint((face>>1)==0), uint((face>>1)==1)) * (float(int(face)&1)*2-1);
    normal = mat3(vxModelView) * normal;
    float astroLightStrength;

    // Comprobar la longitud al cuadrado (dot product) es mucho más rápido que la longitud (sqrt).
    if (dot(normal, normal) > 0.0001) {  // Workaround for undefined normals
        normal = normalize(normal);
        astroLightStrength = dot(normal, astroVector);
    } else {
        normal = vec3(0.0, 1.0, 0.0);
        astroLightStrength = 1.0;
    }

    #if defined THE_END || defined NETHER
        float directLightStrength = astroLightStrength;
    #else
        float directLightStrength = mix(-astroLightStrength, astroLightStrength, dayNightMix);
    #endif

    // Omni light intensity changes by angle
    float omniStrength = ((directLightStrength + 1.0) * 0.25) + 0.75;

    // Calculamos color de luz directa
    #if defined UNKNOWN_DIM
        vec3 directLightColor = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb;
    #else
        vec3 directLightColor = dayBlendVoxy(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR, dayMixerV, nightMixerV, dayMomentV);
        #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
            directLightColor += (endFlashIntensity * endFlashIntensity * 0.1);
        #endif
    #endif
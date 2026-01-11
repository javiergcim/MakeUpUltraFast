#if !defined THE_END && !defined NETHER

    // Fog intensity calculation
    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float fogDensityCoeff = FOG_DENSITY * FOG_ADJUST;
    #else
        float fogDensityCoeff = dayBlendFloat(
            FOG_SUNSET,
            FOG_DAY,
            FOG_NIGHT
        ) * FOG_ADJUST;
    #endif

    float fogIntensityCoeff = max(eyeBrightSmoothFloat.y * 0.004166666666666667, visibleSky);

    #ifdef DISTANT_HORIZONS
        frogAdjust = pow(
            clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fogIntensityCoeff,
            mix(fogDensityCoeff * 0.15, 0.5, rainStrength)
        );
    #else
        frogAdjust = pow(
            clamp(gl_FogFragCoord / far, 0.0, 1.0) * fogIntensityCoeff,
            mix(fogDensityCoeff, 1.0, rainStrength)
        );
    #endif

#else
    #if defined NETHER
        #if NETHER_FOG_DISTANCE == 1
            float sight = NETHER_SIGHT;
        #else
        #if defined DISTANT_HORIZONS
            float sight = dhRenderDistance;
        #else
            float sight = NETHER_SIGHT;
        #endif
        #endif
    #else
        #if defined DISTANT_HORIZONS
            float sight = dhRenderDistance;
        #else
            float sight = far;
        #endif
    #endif
    frogAdjust = sqrt(clamp(gl_FogFragCoord / sight, 0.0, 1.0));
#endif

#ifdef UNKNOWN_DIM
    vec3 horizonSkyColorRGB = fogColor;
    vec3 horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
#else
    vec3 horizonSkyColorRGB = dayBlendVoxy(
        HORIZON_SUNSET_COLOR,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR,
        dayMixerV,
        nightMixerV,
        dayMomentV
    );

    horizonSkyColorRGB = mix(
        horizonSkyColorRGB,
        HORIZON_SKY_RAIN_COLOR * luma(horizonSkyColorRGB),
        rainStrength
    );

    vec3 horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
#endif
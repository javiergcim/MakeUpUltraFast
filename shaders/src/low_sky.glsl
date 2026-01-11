#ifdef UNKNOWN_DIM
    vec3 horizonSkyColorRGB = fogColor;
    horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
#else
    vec3 horizonSkyColorRGB = dayBlend(
        HORIZON_SUNSET_COLOR,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
    );

    horizonSkyColorRGB = mix(
        horizonSkyColorRGB,
        HORIZON_SKY_RAIN_COLOR * luma(horizonSkyColorRGB),
        rainStrength
    );

    horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
#endif
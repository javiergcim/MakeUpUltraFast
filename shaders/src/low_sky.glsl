#ifdef UNKNOWN_DIM
    vec3 horizonSkyColorRGB = fogColor;
    horizonSkyColor = rgb_to_xyz(horizonSkyColorRGB);
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

    horizonSkyColor = rgb_to_xyz(horizonSkyColorRGB);
#endif
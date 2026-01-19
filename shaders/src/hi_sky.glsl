#ifdef UNKNOWN_DIM
    vec3 ZenithSkyColorRGB = skyColor;
    zenithSkyColor = rgbToXyz(ZenithSkyColorRGB);
#else
    vec3 ZenithSkyColorRGB = dayBlend(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        ZENITH_NIGHT_COLOR
    );

    ZenithSkyColorRGB = mix(
        ZenithSkyColorRGB,
        ZENITH_SKY_RAIN_COLOR * luma(ZenithSkyColorRGB),
        rainStrength
    );

    zenithSkyColor = rgbToXyz(ZenithSkyColorRGB);
#endif
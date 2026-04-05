#ifdef UNKNOWN_DIM
    vec3 ZenithSkyColorRGB = skyColor;
    vec3 zenithSkyColor = rgbToXyz(ZenithSkyColorRGB);
#else
    vec3 ZenithSkyColorRGB = dayBlendVoxy(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        ZENITH_NIGHT_COLOR,
        dayMixerV,
        nightMixerV,
        dayMomentV
    );

    ZenithSkyColorRGB = mix(
        ZenithSkyColorRGB,
        ZENITH_SKY_RAIN_COLOR * luma(ZenithSkyColorRGB),
        rainStrength
    );

    vec3 zenithSkyColor = rgbToXyz(ZenithSkyColorRGB);
#endif
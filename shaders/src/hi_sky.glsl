#ifdef UNKNOWN_DIM
    vec3 hi_sky_color_rgb = skyColor;
    hi_sky_color = rgb_to_xyz(hi_sky_color_rgb);
#else
    vec3 hi_sky_color_rgb = day_blend(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        ZENITH_NIGHT_COLOR
    );

    hi_sky_color_rgb = mix(
        hi_sky_color_rgb,
        ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb),
        rainStrength
    );

    hi_sky_color = rgb_to_xyz(hi_sky_color_rgb);
#endif
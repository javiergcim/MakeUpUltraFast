#ifdef UNKNOWN_DIM
    vec3 low_sky_color_rgb = fogColor;
    low_sky_color = rgb_to_xyz(low_sky_color_rgb);
#else
    vec3 low_sky_color_rgb = day_blend(
        HORIZON_SUNSET_COLOR,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
    );

    low_sky_color_rgb = mix(
        low_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(low_sky_color_rgb),
        rainStrength
    );

    low_sky_color = rgb_to_xyz(low_sky_color_rgb);
#endif
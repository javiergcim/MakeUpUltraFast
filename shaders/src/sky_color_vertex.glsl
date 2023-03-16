#ifdef UNKNOWN_DIM
  hi_sky_color = skyColor;
  low_sky_color = fogColor;
#else
  hi_sky_color = day_blend(
    ZENITH_SUNSET_COLOR,
    ZENITH_DAY_COLOR,
    ZENITH_NIGHT_COLOR
  );

  hi_sky_color = mix(
    hi_sky_color,
    ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color),
    rainStrength
  );

  low_sky_color = day_blend(
    HORIZON_SUNSET_COLOR,
    HORIZON_DAY_COLOR,
    HORIZON_NIGHT_COLOR
  );

  low_sky_color = mix(
    low_sky_color,
    HORIZON_SKY_RAIN_COLOR * luma(low_sky_color),
    rainStrength
  );
#endif
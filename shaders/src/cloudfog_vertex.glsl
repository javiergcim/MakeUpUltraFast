#if MAKEUP_COLOR == 1
  // current_fog_color = mix(
  //   low_sky_color_array[current_hour_floor],
  //   low_sky_color_array[current_hour_ceil],
  //   current_hour_fract
  // );
  current_fog_color =
      texture2D(gaux3, vec2(0.833334, current_hour * .04)).rgb;

  current_fog_color = mix(
    current_fog_color,
    LOW_SKY_RAIN_COLOR * luma(current_fog_color),
    rainStrength
  );
#else
  current_fog_color = gl_Fog.color.rgb;
#endif

frog_adjust = 1.0 - (rainStrength * .5);

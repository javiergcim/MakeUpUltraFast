#if MAKEUP_COLOR == 1
  // current_fog_color =
  //     texture2D(gaux3, vec2(LOW_SKY_X, current_hour)).rgb;

  current_fog_color = day_color_mixer(
    LOW_MIDDLE_COLOR,
    LOW_DAY_COLOR,
    LOW_NIGHT_COLOR,
    day_moment
    );

  current_fog_color = mix(
    current_fog_color,
    LOW_SKY_RAIN_COLOR * luma(current_fog_color),
    rainStrength
  );
#else
  current_fog_color = gl_Fog.color.rgb;
#endif

frog_adjust = 1.0 - (rainStrength * .5);

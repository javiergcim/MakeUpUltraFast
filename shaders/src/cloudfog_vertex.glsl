#if MAKEUP_COLOR == 1
  current_fog_color =
      texture2D(gaux3, vec2(LOW_SKY_X, current_hour)).rgb;

  current_fog_color = mix(
    current_fog_color,
    LOW_SKY_RAIN_COLOR * luma(current_fog_color),
    rainStrength
  );
#else
  current_fog_color = gl_Fog.color.rgb;
#endif

frog_adjust = 1.0 - (rainStrength * .5);

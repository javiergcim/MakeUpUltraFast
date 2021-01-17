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

frog_adjust = 1.0 - (rainStrength * .5);

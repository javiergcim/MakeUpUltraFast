vec3 low_sky_color = mix(
  low_sky_color_array[current_hour_floor],
  low_sky_color_array[current_hour_ceil],
  current_hour_fract
);

block_color.rgb =
  mix(
    block_color.rgb,
    low_sky_color,
    pow(clamp(frog_adjust, 0.0, 1.0), mix(fog_density_coeff, .5, rainStrength)) * .75
  );

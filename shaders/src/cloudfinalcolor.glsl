#if MAKEUP_COLOR == 1
vec3 low_sky_color = mix(
  low_sky_color_array[current_hour_floor],
  low_sky_color_array[current_hour_ceil],
  current_hour_fract
);
#else
  vec3 low_sky_color = gl_Fog.color.rgb;
#endif

block_color.rgb =
  mix(
    block_color.rgb,
    low_sky_color,
    clamp(pow(ld(gl_FragCoord.z), 2.0), 0.0, 1.0) * (1.0 - (rainStrength * .5))
  );

// block_color.rgb = vec3(gl_FogFragCoord / far);
// block_color.rgb = vec3(ld(gl_FragCoord.z));

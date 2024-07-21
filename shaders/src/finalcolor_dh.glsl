#if defined DH_WATER
  if (isEyeInWater == 0) {
    vec3 fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb;
    block_color.rgb =
      mix(
        block_color.rgb,
        fog_texture,
        frog_adjust
      );
  }
#elif defined NETHER
  block_color.rgb =
    mix(
      block_color.rgb,
      mix(fogColor * 0.1, vec3(1.0), 0.04),
      frog_adjust
    );
#else
  vec3 fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb;
  block_color.rgb =
    mix(
      block_color.rgb,
      fog_texture,
      frog_adjust
    );
#endif
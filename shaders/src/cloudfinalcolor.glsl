block_color.rgb =
  mix(
    block_color.rgb,
    texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb,
    #if defined GBUFFER_CLOUDS
      clamp(pow(gl_FogFragCoord / (far * 2.0), 2.0), 0.0, 1.0) * frog_adjust * 0.8
    #else
      clamp(pow(gl_FogFragCoord / far, 2.0), 0.0, 1.0) * frog_adjust * 0.8
    #endif
  );

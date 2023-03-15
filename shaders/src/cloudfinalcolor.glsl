block_color.rgb =
  mix(
    block_color.rgb,
    texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb,
    clamp(pow(gl_FogFragCoord / (far * 1.66), 1.5), 0.0, 1.0)
  );

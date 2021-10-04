block_color.rgb =
  mix(
    block_color.rgb,
    texture(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb,
    clamp(pow(var_fog_frag_coord / far, 2.0), 0.0, 1.0) * frog_adjust * .8
  );

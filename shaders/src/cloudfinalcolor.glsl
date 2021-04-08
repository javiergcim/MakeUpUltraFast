block_color.rgb =
  mix(
    block_color.rgb,
    current_fog_color,
    clamp(pow(gl_FogFragCoord / far, 2.0), 0.0, 1.0) * frog_adjust * .8
  );

// block_color.a *= (1.0 - (gl_FogFragCoord / far));

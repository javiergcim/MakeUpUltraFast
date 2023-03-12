block_color.rgb =
  mix(
    block_color.rgb,
    sky_base,
    clamp(pow(gl_FogFragCoord / (far * 1.66), 1.5), 0.0, 1.0) * frog_adjust
  );

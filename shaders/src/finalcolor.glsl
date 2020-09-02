block_color.rgb =
  mix(
    block_color.rgb,
    current_fog_color,
    pow(clamp(frog_adjust, 0.0, 1.0), mix(fog_density_coeff, .5, wetness))
  );

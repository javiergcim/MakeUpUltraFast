block_color.rgb =
  mix(
    block_color.rgb,
    gl_Fog.color.rgb,
    pow(clamp(frog_adjust, 0.0, 1.0), mix(fog_density_coeff, .5, rainStrength)) * .75
  );

frog_adjust = gl_FogFragCoord / far;
// Fog intensity calculation
fog_density_coeff = mix(
  fog_density[current_hour_floor],
  fog_density[current_hour_ceil],
  current_hour_fract
  );

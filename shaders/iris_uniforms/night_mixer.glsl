float night_mixer(float day_moment) {
  float moment_aux_3 = day_moment - 0.75;

  return clamp(-(moment_aux_3 * moment_aux_3) * 50.0 + 3.125, 0.0, 1.0);
}
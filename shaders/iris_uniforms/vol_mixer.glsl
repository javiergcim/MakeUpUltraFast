float vol_mixer(float day_moment) {
  float moment_aux_5 = (day_moment * 4.0) - 1.0;
  float day_vol_mixer = clamp(((-(moment_aux_5 * moment_aux_5 * moment_aux_5 * moment_aux_5) + 1.0) * 7.0) + 1.0, 1.0, 8.0);

  float moment_aux_7 = (day_moment * 4.0) - 3.0;
  float night_vol_mixer = clamp(((-(moment_aux_7 * moment_aux_7 * moment_aux_7 * moment_aux_7) + 1.0) * 7.0) + 1.0, 1.0, 8.0);

  return max(day_vol_mixer, night_vol_mixer);
}

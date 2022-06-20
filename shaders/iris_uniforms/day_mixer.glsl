float day_mixer(float day_moment) {
  float moment_aux = day_moment - 0.25;
  
  return clamp(-(moment_aux * moment_aux) * 20.0 + 1.25, 0.0, 1.0);
}
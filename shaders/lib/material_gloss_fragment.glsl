float material_gloss(vec3 fragpos, vec2 lmcoord_alt, float gloss_power) {
  vec3 astro_pos = worldTime > 12900 ? moonPosition : sunPosition;
  float astro_vector =
    max(dot(normalize(fragpos), normalize(astro_pos)), 0.0);

  return clamp(
      mix(0.0, 1.0, pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), gloss_power)) *
      clamp(lmcoord_alt.y, 0.0, 1.0) *
      (1.0 - rainStrength),
      0.0,
      1.0
    );
}
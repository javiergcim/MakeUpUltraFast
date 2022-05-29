float material_gloss(vec3 fragpos, vec2 lmcoord_alt) {
  vec3 astro_pos = worldTime > 12900 ? moonPosition : sunPosition;
  float astro_vector =
    max(dot(normalize(fragpos), normalize(astro_pos)), 0.0);

  return clamp(
      // smoothstep(0.875, 1.0, pow(astro_vector, 0.5)) *
      mix(0.0, 1.0, pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), 7.0)) *
      clamp(lmcoord_alt.y, 0.0, 1.0) *
      (1.0 - rainStrength),
      0.0,
      1.0
    ) * 2.5;
}
  
vec3 get_mat_normal(vec3 material_normal, vec3 tangent, vec3 binormal, vec3 sub_position) {
  float NdotE = abs(dot(material_normal, normalize(sub_position)));

  mat3 tbn_matrix = mat3(
    tangent.x, binormal.x, material_normal.x,
    tangent.y, binormal.y, material_normal.y,
    tangent.z, binormal.z, material_normal.z
    );

  return normalize(vec3(0.0, 0.0, 1.0) * tbn_matrix);
}
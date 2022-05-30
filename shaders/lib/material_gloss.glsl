vec3 get_mat_normal(vec3 material_normal, vec3 tangent, vec3 binormal, vec3 sub_position) {
  float NdotE = abs(dot(material_normal, normalize(sub_position)));

  mat3 tbn_matrix = mat3(
    tangent.x, binormal.x, material_normal.x,
    tangent.y, binormal.y, material_normal.y,
    tangent.z, binormal.z, material_normal.z
    );

  return normalize(vec3(0.0, 0.0, 1.0) * tbn_matrix);
}
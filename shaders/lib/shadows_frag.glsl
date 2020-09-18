vec3 get_shadow(){
  vec3 shadow_color = vec3(0.0, 0.0, 0.0);

  if (shadow_pos.x > 0.0 && shadow_pos.x < 1.0 &&
      shadow_pos.y > 0.0 && shadow_pos.y < 1.0 &&
      shadow_pos.z > 0.0 && shadow_pos.z < 1.0) {
        shadow_color = vec3(shadow2D(shadowtex0, shadow_pos).z);

  return shadow_color;
}

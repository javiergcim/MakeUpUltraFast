/* MakeUp Ultra Fast - water.glsl
Cristal reflection related functions. Based by Project LUMA.

*/

vec4 cristal_reflection_calc(vec3 fragpos, vec3 normal) {
  vec3 reflected_vector = reflect(normalize(fragpos), normal) * 30.0;
  vec3 pos = camera_to_screen(fragpos + reflected_vector);

  float border_x = max(-fourth_pow(abs(2 * pos.x - 1.0)) + 1.0, 0.0);
  float border_y = max(-fourth_pow(abs(2 * pos.y - 1.0)) + 1.0, 0.0);
  float border = min(border_x, border_y);

  return vec4(texture2D(gaux1, pos.xy, 0.0).rgb, border);
}

vec4 cristal_shader(vec3 fragpos, vec3 normal, vec4 color, vec3 sky_reflection) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = cristal_reflection_calc(fragpos, normal);
  #endif

  reflection.rgb = mix(sky_reflection * lmcoord.y * lmcoord.y, reflection.rgb, reflection.a);

  float normal_dot_eye = dot(normal, normalize(fragpos));
  float fresnel = clamp(fifth_pow(1.0 + normal_dot_eye) + 0.1, 0.0, 1.0);

  float reflection_index = min(fresnel * (-color.a + 1.0) * 2.0, 1.0);

  color.rgb = mix(color.rgb, sky_reflection, reflection_index);
  color.rgb = mix(color.rgb, reflection.rgb, reflection_index);

  color.a = mix(color.a, 1.0, fresnel * .8);

  #if SUN_REFLECTION == 1
     #ifndef NETHER
      #ifndef THE_END
        return color +
          vec4(
            mix(
              sun_reflection(reflect(normalize(fragpos), normal)),
              vec3(0.0),
              reflection.a
            ),
            0.0
          );
      #else
        return color;
      #endif
    #else
      return color;
    #endif
  #else
    return color;
  #endif
}

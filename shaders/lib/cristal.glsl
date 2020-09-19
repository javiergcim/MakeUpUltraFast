/* MakeUp Ultra Fast - water.glsl
Cristal reflection related functions. Based by Project LUMA.

*/

vec4 cristal_raytrace(vec3 fragpos, vec3 normal) {

  #if SSR_METHOD == 0

    vec3 reflected_vector = reflect(normalize(fragpos), normal) * 30.0;
    vec3 pos = camera_to_screen(fragpos + reflected_vector);

    float border_x = max(-fourth_pow(abs(2 * pos.x - 1.0)) + 1.0, 0.0);
    float border_y = max(-fourth_pow(abs(2 * pos.y - 1.0)) + 1.0, 0.0);
    float border = min(border_x, border_y);

    return vec4(texture2D(gaux2, pos.xy, 0.0).rgb, border);

  #else

    #if AA_TYPE == 2
      float dither = timed_hash12();
    #else
      float dither = grid_noise();
    #endif

    const int samples = RT_SAMPLES;
    const int max_refinement = 10;
    const float step_size = 1.2;
    const float step_refine = 0.28;
    const float step_increment = 1.8;

    vec3 col = vec3(0.0);
    vec3 ray_start = fragpos;
    vec3 ray_dir = reflect(normalize(fragpos), normal);
    vec3 ray_step = (step_size + dither - 0.5) * ray_dir;
    vec3 ray_pos = ray_start + ray_step;
    vec3 ray_pos_past = ray_start;
    vec3 ray_refine = ray_step;

    int refine = 0;
    vec3 pos = vec3(0.0);
    float border = 0.0;

    for (int i = 0; i < samples; i++) {

      pos = camera_to_screen(ray_pos);

      if (pos.x < 0.0 ||
          pos.x > 1.0 ||
          pos.y < 0.0 ||
          pos.y > 1.0 ||
          pos.z < 0.0 ||
          pos.z > 1.0) break;

      vec3 screenPos = vec3(pos.xy, texture2D(depthtex1, pos.xy).x);
       screenPos = camera_to_world(screenPos * 2.0 - 1.0);

      float dist = distance(ray_pos, screenPos);

      if (
        dist < pow(length(ray_step) * pow(length(ray_refine), 0.11), 1.1) * 1.22
        ) {

        refine++;
        if (refine >= max_refinement) break;

        ray_refine -= ray_step;
        ray_step *= step_refine;
      }

      ray_step *= step_increment;
      ray_pos_past = ray_pos;
      ray_refine += ray_step;
      ray_pos = ray_start+ray_refine;

    }

    if (pos.z < 1.0-1e-5) {
      float depth = texture2D(depthtex0, pos.xy).x;

      float comp = 1.0 - near / far / far;
      bool land = depth < comp;

      if (land) {
        col = texture2D(gaux2, pos.xy).rgb;
        border = clamp((1.0 - cdist(pos.st)) * 50.0, 0.0, 1.0);
      }
    }

    // Difumina la orilla del área reflejable para evitar el "corte" del mismo.
    float border_mix = abs((pos.x * 2.0) - 1.0);
    border_mix *= border_mix;
    border = mix(border, 0.0, border_mix);

    return vec4(col, border);

  #endif
}

vec4 cristal_shader(vec3 fragpos, vec3 normal, vec4 color, vec3 sky_reflection) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = cristal_raytrace(fragpos, normal);
  #endif

  reflection.rgb = mix(sky_reflection * lmcoord.y * lmcoord.y, reflection.rgb, reflection.a);

  float normal_dot_eye = dot(normal, normalize(fragpos));
  float fresnel = clamp(fifth_pow(1.0 + normal_dot_eye) + 0.1, 0.0, 1.0);

  float reflection_index = min(fresnel * (-color.a + 1.0) * 2.0, 1.0);

  color.rgb = mix(color.rgb, sky_reflection, reflection_index);
  color.rgb = mix(color.rgb, reflection.rgb, reflection_index);

  color.a = mix(color.a, 1.0, fresnel * .8);

  // return color;

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

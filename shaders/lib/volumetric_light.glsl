/* MakeUp - volumetric_clouds.glsl
Volumetric light - MakeUp implementation
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

vec3 get_volumetric_pos(vec3 the_pos) {
  vec3 shadow_pos = mat3(shadowModelView) * the_pos + shadowModelView[3].xyz;
  shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

  float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
  shadow_pos.xy /= distortion;
  shadow_pos.xyz = shadow_pos.xyz * 0.5 + 0.5;

  return shadow_pos;
}

float get_volumetric_light(float dither, float view_distance) {
  float light = 0.0;

  float current_depth;
  vec3 view_pos;
	vec4 pos;
  vec3 shadow_pos;

  for (int i = 0; i < GODRAY_STEPS; i++) {
    // Exponentialy spaced shadow samples
    current_depth = exp2(i + dither) - 0.96;  // 0.96 avoids points behind near plane
    if (current_depth > view_distance) {
      break;
    }

    // Distance to depth
		current_depth = (far * (current_depth - near)) / (current_depth * (far - near));

    view_pos = vec3(texcoord, current_depth);

		// Clip to world
		pos = gbufferModelViewInverse * gbufferProjectionInverse * (vec4(view_pos, 1.0) * 2.0 - 1.0);
	  view_pos = (pos.xyz /= pos.w).xyz;

    shadow_pos = get_volumetric_pos(view_pos);

    light += texture(shadowtex1, shadow_pos);
  }

  light /= GODRAY_STEPS;

  return light;
}

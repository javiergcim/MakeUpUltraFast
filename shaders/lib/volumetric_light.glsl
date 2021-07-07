/* MakeUp - volumetric_clouds.glsl
Volumetric light - MakeUp implementation
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

float distance_to_depth(float d) {
	return (far * (d - near)) / (d * (far - near));
}

float depth_to_distance(float depth) {
    return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}

vec3 clip_to_world(vec3 fragpos) {
  vec4 pos = gbufferModelViewInverse * gbufferProjectionInverse * (vec4(fragpos, 1.0) * 2.0 - 1.0);
  pos.xyz /= pos.w;

  return pos.xyz;
}

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
  vec3 shadow_pos;

  for (int i = 0; i < GODRAY_STEPS; i++) {
    // Exponentialy spaced shadow samples
    current_depth = exp2(i + dither) - 0.95;  // 0.95 avoids points behind near plane
    // current_depth = exp2(i) - 0.95;
    if (current_depth > view_distance) {
      break;
    }

    current_depth = distance_to_depth(current_depth);
    view_pos = vec3(texcoord, current_depth);
    view_pos = clip_to_world(view_pos);
    shadow_pos = get_volumetric_pos(view_pos);

    light += shadow2D(shadowtex1, shadow_pos).x;
  }

  light /= GODRAY_STEPS;

  // light = light / (GODRAY_STEPS * 2.0);
  // light = light + (0.5 * float(light > 0.00001));

  // light = sqrt(light);
  return light;
}

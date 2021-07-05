/* MakeUp - volumetric_clouds.glsl
Volumetric light - MakeUp implementation
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

vec3 camera_to_world(vec3 fragpos) {
  vec4 pos = gbufferModelViewInverse * gbufferProjectionInverse * (vec4(fragpos, 1.0) * 2.0 - 1.0);
  pos.xyz /= pos.w;

  return pos.xyz;
}

vec3 get_volumetric_pos(vec3 the_pos, float NdotL) {
  vec3 shadow_pos = mat3(shadowModelView) * the_pos + shadowModelView[3].xyz;
  shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

  float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
  shadow_pos.xy /= distortion;

  float bias = distortion * distortion * (0.0046 * tan(acos(NdotL)));

  shadow_pos.xyz = shadow_pos.xyz * 0.5 + 0.5;
  shadow_pos.z -= bias;

  return shadow_pos;
}

float get_volumetric_light(float dither, float view_depth) {
  float light = 0.0;

  // float increment = ((shadowDistance / far) * 0.5) / GODRAY_STEPS;  // Medio camino al cielo
  float increment = 0.5 / GODRAY_STEPS;  // Medio camino al cielo
  float current_depth = increment * dither;
  vec3 view_pos;
  vec3 shadow_pos;

  for (int i = 0; i < GODRAY_STEPS; i++) {
    if (current_depth > view_depth) {
      break;
    }

    view_pos = vec3(texcoord, current_depth);
    view_pos.z = pow(view_pos.z, 0.005);
    view_pos = camera_to_world(view_pos);
    shadow_pos = get_volumetric_pos(view_pos, 1.0);

    light += get_shadow(shadow_pos);

    current_depth += increment;
  }

  light /= GODRAY_STEPS;

  return light;
}

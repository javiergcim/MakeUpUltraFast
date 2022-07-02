/* MakeUp - shadow_vertex.glsl
Vertex shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

vec3 get_shadow_pos(vec3 shadow_pos, float NdotL) {
  shadow_pos = mat3(shadowModelView) * shadow_pos + shadowModelView[3].xyz;
  shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

  float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
  shadow_pos.xy /= distortion;

  #if SHADOW_RES == 0 || SHADOW_RES == 1 || SHADOW_RES == 2
    #define S_BIAS 0.00175
  #elif SHADOW_RES == 3 || SHADOW_RES == 4 || SHADOW_RES == 5
    #define S_BIAS 0.0021
  #elif SHADOW_RES == 6 || SHADOW_RES == 7 || SHADOW_RES == 8
    #define S_BIAS 0.0012
  #endif

  // float bias = distortion * distortion * (S_BIAS * tan(acos(NdotL)));
  float bias = distortion * distortion * ((S_BIAS * (1.0 / NdotL)) - S_BIAS);

  shadow_pos.xyz = shadow_pos.xyz * 0.5 + 0.5;
  shadow_pos.z -= bias;

  return shadow_pos;
}

/* MakeUp - projection_utils.glsl
Projection generic functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

vec3 to_screen_space(vec3 p) {
  vec4 i_proj_diag =
    vec4(
      gbufferProjectionInverse[0].x,
      gbufferProjectionInverse[1].y,
      gbufferProjectionInverse[2].zw
    );
  vec3 p3 = p * 2.0 - 1.0;
  vec4 fragposition = i_proj_diag * p3.xyzz + gbufferProjectionInverse[3];
  return fragposition.xyz / fragposition.w;
}

vec3 camera_to_world(vec3 fragpos) {
  vec4 pos  = gbufferProjectionInverse * vec4(fragpos, 1.0);
  pos /= pos.w;

  return pos.xyz;
}

vec3 camera_to_screen(vec3 fragpos) {
  vec4 pos  = gbufferProjection * vec4(fragpos, 1.0);
   pos /= pos.w;

  return pos.xyz * 0.5 + 0.5;
}

/* MakeUp - past_projection_utils.glsl
Projection functions from past frame.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 to_clip_space(vec3 view_space_pos) {
  return projMAD(gbufferPreviousProjection, view_space_pos) / -view_space_pos.z * 0.5 + 0.5;
}

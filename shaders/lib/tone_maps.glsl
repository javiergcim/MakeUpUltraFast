/* MakeUp Ultra Fast - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 tonemap(vec3 x){
  return x / pow(vec3_fourth_pow(x) + 1.0, vec3(.25));
}

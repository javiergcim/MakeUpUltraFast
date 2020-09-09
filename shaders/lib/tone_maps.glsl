/* MakeUp Ultra Fast - tone_maps.glsl
Tone map related functions.
*/

vec3 tonemap(vec3 x){
  return x / pow(vec3_fourth_pow(x) + 1.0, vec3(.25));
}

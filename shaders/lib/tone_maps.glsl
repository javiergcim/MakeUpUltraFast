/* MakeUp Ultra Fast - tone_maps.glsl
Tone map related functions.
*/

vec3 tonemap(vec3 x){
  return x / pow(pow(x, vec3(4.0)) + 1.0, vec3(.25));
}

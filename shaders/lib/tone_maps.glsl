/* MakeUp Ultra Fast - tone_maps.glsl
Tone map related functions.
*/

vec3 tonemap(vec3 x){
  return x / pow(pow(x, vec3(4.0)) + 1.0, vec3(.25));
  // return 2.0 * (pow((1.0 + exp(-(x * 4.5 - 3.434))), vec3(-.2))) - 1;
}

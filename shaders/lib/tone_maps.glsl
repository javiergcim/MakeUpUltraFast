/* MakeUp Ultra Fast - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 tonemap(vec3 x) {
  return x / pow(vec3_fourth_pow(x) + 1.0, vec3(.25));
}

vec3 aces_tonemap(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

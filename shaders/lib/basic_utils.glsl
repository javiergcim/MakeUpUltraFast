/* MakeUp - basic_utils.glsl
Misc utilities.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float square_pow(float x) {
  return x * x;
}

float cube_pow(float x) {
  return x * x * x;
}

float fourth_pow(float x) {
  float temp_2 = x * x;
  return temp_2 * temp_2;
}

float fifth_pow(float x) {
  float temp_2 = x * x;
  return temp_2 * temp_2 * x;
}

float sixth_pow(float x) {
  float temp_2 = x * x;
  return temp_2 * temp_2 * temp_2;
}

vec3 vec3_square_pow(vec3 x) {
  return x * x;
}

vec3 vec3_cube_pow(vec3 x) {
  return x * x * x;
}

vec3 vec3_fourth_pow(vec3 x) {
  vec3 temp_2 = x * x;
  return temp_2 * temp_2;
}

vec3 vec3_fifth_pow(vec3 x) {
  vec3 temp_2 = x * x;
  return temp_2 * temp_2 * x;
}

vec3 vec3_sixth_pow(vec3 x) {
  vec3 temp_2 = x * x;
  return temp_2 * temp_2 * temp_2;
}

vec4 vec4_square_pow(vec4 x) {
  return x * x;
}

vec4 vec4_cube_pow(vec4 x) {
  return x * x * x;
}

vec4 vec4_fourth_pow(vec4 x) {
  return x * x * x * x;
}

vec4 vec3_fifth_pow(vec4 x) {
  vec4 temp_2 = x * x;
  return temp_2 * temp_2 * x;
}

vec4 vec3_sixth_pow(vec4 x) {
  vec4 temp_2 = x * x;
  return temp_2 * temp_2 * temp_2;
}

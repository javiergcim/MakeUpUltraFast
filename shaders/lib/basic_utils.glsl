/* MakeUp Ultra Fast - basic_utils.glsl
Misc utilities.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float ld(float depth) {
	return (2.0 * near) / (far + near - depth * (far - near));
}

float square_pow(float x) {
  return x * x;
}

float cube_pow(float x) {
  return x * x * x;
}

float fourth_pow(float x) {
  return x * x * x * x;
}

vec3 vec3_square_pow(vec3 x) {
  return x * x;
}

vec3 vec3_cube_pow(vec3 x) {
  return x * x * x;
}

vec3 vec3_fourth_pow(vec3 x) {
  return x * x * x * x;
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

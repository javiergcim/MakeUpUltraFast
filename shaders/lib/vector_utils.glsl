/* MakeUp Ultra Fast - vector_utils.glsl
Functions for waving entities.

*/

vec3 wave_move(vec2 pos) {
  float timer = (frameTimeCounter) * 3.141592;
  pos = mod(pos, 157.07963267948966);  // PI * 25
  vec2 wave_x = vec2(timer * .5, timer) + pos;
  vec2 wave_z = vec2(timer, timer * 1.5) + pos;

  wave_x = sin(wave_x);
  wave_z = cos(wave_z);
  return vec3(wave_x.x + wave_x.y, 0.0, wave_z.x + wave_z.y);
}

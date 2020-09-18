/* MakeUp Ultra Fast - vector_utils.glsl
Functions for waving entities.

Wave and move functions based on Sildur's Shaders
*/

float frame_time_m = 150.0 * frameTimeCounter;

vec3 vertex_wave(
  vec3 pos,
  float fm,
  float mm,
  float ma,
  float f0,
  float f1,
  float f2,
  float f3,
  float f4,
  float f5
) {
  float magnitude = sin(frame_time_m * fm + dot(pos, vec3(0.5))) * mm + ma;
  vec3 d012 = sin(vec3(f0, f1, f2) * frame_time_m);

  vec3 ret;
  ret.x = frame_time_m * f3 + d012.x + d012.y - pos.x + pos.z + pos.y;
  ret.z = frame_time_m * f4 + d012.y + d012.z + pos.x - pos.z + pos.y;
  ret.y = frame_time_m * f5 + d012.z + d012.x + pos.z + pos.y - pos.y;
  ret = sin(ret) * magnitude;

  return ret;
}

vec3 wave_move(
  in vec3 pos,
  in float f0,
  in float f1,
  in float f2,
  in float f3,
  in float f4,
  in float f5,
  in vec3 amp1,
  in vec3 amp2
) {
  vec3 move1 = vertex_wave(
    pos,
    0.0027,
    0.0400,
    0.0400,
    0.0127,
    0.0089,
    0.0114,
    0.0063,
    0.0224,
    0.0015
  ) * amp1;
  vec3 move2 = vertex_wave(
    pos + move1,
    0.0348,
    0.0400,
    0.0400,
    f0,
    f1,
    f2,
    f3,
    f4,
    f5) * amp2;

  return move1 + move2;
}

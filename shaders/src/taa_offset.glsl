uniform float pixel_size_x;
uniform float pixel_size_y;
uniform int frame_mod;
vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);

// Custom penta star
const vec2[5] offsets = vec2[5](
  vec2(0.69138184, 0.10950412),
  vec2(0.10950412, 0.69138184),
  vec2(-0.62370456,  0.31779335),
  vec2(-0.49497475, -0.49497475),
  vec2(0.31779335, -0.62370456)
);

// Halton 8
// const vec2[8] offsets = vec2[8](
//   vec2(0.125, -0.375) * .8,
//   vec2(-0.125, 0.375) * .8,
//   vec2(0.625, 0.125) * .8,
//   vec2(-0.375, -0.625) * .8,
//   vec2(-0.625, 0.625) * .8,
//   vec2(-0.875, -0.125) * .8,
//   vec2(0.375, 0.875) * .8,
//   vec2(0.875, -0.875) * .8
// );

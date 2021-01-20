uniform float pixel_size_x;
uniform float pixel_size_y;
uniform int frame_mod;
vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);

// Custom penta star
const vec2[5] offsets = vec2[5](
  vec2(0.55310547, 0.0876033),
  vec2(0.0876033 , 0.55310547),
  vec2(-0.49896365, 0.25423468),
  vec2(-0.3959798 , -0.3959798),
  vec2(0.25423468, -0.49896365)
);

// Halton 8
// const vec2[8] offsets = vec2[8](
//   vec2(0.125, -0.375) * .75,
//   vec2(-0.125, 0.375) * .75,
//   vec2(0.625, 0.125) * .75,
//   vec2(-0.375, -0.625) * .75,
//   vec2(-0.625, 0.625) * .75,
//   vec2(-0.875, -0.125) * .75,
//   vec2(0.375, 0.875) * .75,
//   vec2(0.875, -0.875) * .75
// );

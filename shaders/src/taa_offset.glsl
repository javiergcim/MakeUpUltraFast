uniform float pixel_size_x;
uniform float pixel_size_y;
uniform int frame_mod;
vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);

// Penta star
const vec2[5] offsets = vec2[5](
  vec2(0.108, -0.5315625),
  vec2(0.199125, 0.529875),
  vec2(-0.4995, -0.2750625),
  vec2(0.5383125, -0.03375),
  vec2(-0.442125, 0.381375)
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

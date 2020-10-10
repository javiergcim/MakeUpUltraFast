uniform float pixelSizeX;
uniform float pixelSizeY;
uniform int frame_mod;
vec2 texelSize = vec2(pixelSizeX, pixelSizeY);

// Penta star
const vec2[5] offsets = vec2[5](
  vec2(.144, -0.70875),
  vec2(.2655, .7065),
  vec2(-.666, -.36675),
  vec2(.71775, -.045),
  vec2(-.5895, .5085)
);

// Halton 8
// const vec2[8] offsets = vec2[8](
//   vec2(0.125,-0.375),
//   vec2(-0.125,0.375),
//   vec2(0.625,0.125),
//   vec2(-0.375,-0.625),
//   vec2(-0.625,0.625),
//   vec2(-0.875.,-0.125),
//   vec2(0.375,0.875),
//   vec2(0.875,-0.875)
// );

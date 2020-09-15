uniform float pixelSizeX;
uniform float pixelSizeY;
uniform int frame8;
vec2 texelSize = vec2(pixelSizeX, pixelSizeY);

// Halton 8
// const vec2[8] offsets = vec2[8](
// 	vec2( 0.125,-0.375),
// 	vec2(-0.125, 0.375),
// 	vec2( 0.625, 0.125),
// 	vec2( 0.375,-0.625),
// 	vec2(-0.625, 0.625),
// 	vec2(-0.875,-0.125),
// 	vec2( 0.375,-0.875),
// 	vec2( 0.875, 0.875)
// );

// Helix
const vec2[4] offsets = vec2[4](
  vec2(-.3, .2),
  vec2(.3,-.2),
  vec2(.2,.3),
  vec2(-.2,-.3)
);

// Penta
// const vec2[5] offsets = vec2[5](
//   vec2(.096, -0.4725),
//   vec2(.177, .471),
//   vec2(-.444, -.2445),
//   vec2(.4785, -.03),
//   vec2(-.393, .339)
// );

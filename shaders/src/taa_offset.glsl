uniform float pixelSizeX;
uniform float pixelSizeY;
uniform int frame8;
vec2 texelSize = vec2(pixelSizeX, pixelSizeY);
const vec2[8] offsets = vec2[8](
  vec2(1./14.,-3./14.),
  vec2(-1.,3.)/14.,
  vec2(5.0,1.)/14.,
  vec2(-3,-5.)/14.,
  vec2(-5.,5.)/14.,
  vec2(-7.,-1.)/14.,
  vec2(3,7.)/14.,
  vec2(7.,-7.)/14.
);

uniform float pixelSizeX;
uniform float pixelSizeY;
uniform int frame8;
vec2 texelSize = vec2(pixelSizeX, pixelSizeY);

// Penta star
const vec2[5] offsets = vec2[5](
  vec2(.144, -0.70875),
  vec2(.2655, .7065),
  vec2(-.666, -.36675),
  vec2(.71775, -.045),
  vec2(-.5895, .5085)
);

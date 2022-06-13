/* MakeUp - dither.glsl
Dither and hash functions

*/

uniform float dither_shift;

float hash12(vec2 v)
{
  v = 0.0002314814814814815 * v + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  return fract(state * state * 7142.0);
}

float shifted_hash12(vec2 v)
{
  v = 0.0002314814814814815 * v + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  return fract(dither_shift + (state * state * 7142.0));
}

float r_dither(vec2 frag) {
  return fract(dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float shifted_r_dither(vec2 frag) {
  return fract(dither_shift + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float eclectic_r_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.175;

  return fract(p4 + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float shifted_eclectic_r_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.175;

  return fract(dither_shift + p4 + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float dither17(vec2 pos) {
  return fract(dot(vec3(pos, 0.0), vec3(0.11764705882352941, 0.4117647058823529, 1.3529411764705883)));
}

float shifted_dither17(vec2 pos) {
  return fract(dither_shift + dot(vec3(pos, 0.0), vec3(0.11764705882352941, 0.4117647058823529, 1.3529411764705883)));
}

float eclectic_dither17(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.14;

  return fract(p4 + dot(vec3(frag.xy, 0.0), vec3(2.0, 7.0, 23.0) / 17.0));
}

float shifted_eclectic_dither17(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.14;

  return fract(dither_shift + p4 + dot(vec3(frag.xy, 0.0), vec3(2.0, 7.0, 23.0) / 17.0));
}

float dither_grad_noise(vec2 p) {
  return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

float shifted_dither_grad_noise(vec2 p) {
  return fract(dither_shift + (52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y)));
}

float eclectic_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.14;

  return fract(p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
}

float shifted_eclectic_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.14;

  return fract(dither_shift + p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
}

// float texture_noise_64(vec2 p, sampler2D noise) {
//   return texture2D(noise, p * 0.015625).r;
// }

// float shifted_texture_noise_64(vec2 p, sampler2D noise) {
//   float dither = texture2D(noise, p * 0.015625).r;
//   return fract(dither_shift + dither);
// }

float phinoise(vec2 xy) {
  vec2 tile = floor(xy * 0.25);
  float flip = mod(tile.x + tile.y, 2.0);
  xy = mix(xy, xy.yx, flip);

  return fract(dot(vec2(0.75487766624669276, 0.569840290998), xy) + hash12(tile));
}

float shifted_phinoise(vec2 xy) {
  vec2 tile = floor(xy * 0.25);
  float flip = mod(tile.x + tile.y, 2.0);
  xy = mix(xy, xy.yx, flip);

  return fract(dither_shift + dot(vec2(0.75487766624669276, 0.569840290998), xy) + hash12(tile));
}

float unit_dither(vec2 frag) {
  return (mod(dot(vec2(9.0, 5.0), frag), 11.0) + 0.5) * 0.09090909090909091;
}

float shifted_unit_dither(vec2 frag) {
  return fract(dither_shift + ((mod(dot(vec2(9.0, 5.0), frag), 11.0) + 0.5) * 0.09090909090909091));
}

float eclectic_unit_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.14;

  return fract(p4 + ((mod(dot(vec2(9.0, 5.0), frag), 11.0) + 0.5) * 0.09090909090909091));
}

float shifted_eclectic_unit_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.14;

  return fract(dither_shift + p4 + ((mod(dot(vec2(9.0, 5.0), frag), 11.0) + 0.5) * 0.09090909090909091));
}

float makeup_dither(vec2 frag) {
  return fract(dot(frag, vec2(0.5562305898749054, 0.8085512046226566)));
}

float eclectic_makeup_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.175;

  return fract(p4 + dot(frag, vec2(0.5562305898749054, 0.8085512046226566)));
}

float shifted_makeup_dither(vec2 frag) {
  return fract(dither_shift + dot(frag, vec2(0.5562305898749054, 0.8085512046226566)));
}

float shifted_eclectic_makeup_dither(vec2 frag) {
  vec2 v = 0.0002314814814814815 * frag + vec2(0.25, 0.0);
  float state = fract(dot(v * v, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.175;

  return fract(dither_shift + p4 + dot(frag, vec2(0.5562305898749054, 0.8085512046226566)));
}

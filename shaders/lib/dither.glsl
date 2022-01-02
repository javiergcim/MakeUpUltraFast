/* MakeUp - dither.glsl
Dither and hash functions

*/

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float timed_hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract(0.1 * frame_mod + ((p3.x + p3.y) * p3.z));
}

float dither_grad_noise(vec2 p) {
  return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

float shifted_dither_grad_noise(vec2 p) {
  return fract(0.1 * frame_mod + (52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y)));
}

float eclectic_dither(vec2 frag) {
  vec3 p3 = fract(vec3(frag.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  float p4 = fract((p3.x + p3.y) * p3.z) * 0.14;

  return fract(p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
}

float shifted_eclectic_dither(vec2 frag) {
  vec3 p3 = fract(vec3(frag.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  float p4 = fract((p3.x + p3.y) * p3.z) * 0.14;

  return fract((0.1 * frame_mod) + p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
}

// float grid_noise(vec2 p) {
//   return fract(
//     dot(
//       p - vec2(0.5, 0.5),
//       vec2(0.0625, .277777777777777777778) + 0.25
//       )
//     );
// }

// float shifted_grid_noise(vec2 p) {
//   return fract(0.4 * frame_mod +
//     dot(
//       p - vec2(0.5, 0.5),
//       vec2(0.0625, .277777777777777777778) + 0.25
//       )
//     );
// }

float texture_noise_64(vec2 p, sampler2D noise) {
  return texture2D(noise, p * 0.015625).r;
}

float shifted_texture_noise_64(vec2 p, sampler2D noise) {
  float dither = texture2D(noise, p * 0.015625).r;
  return fract(0.1 * frame_mod + dither);
}

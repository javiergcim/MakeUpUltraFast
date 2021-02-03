/* MakeUp Ultra Fast - dither.glsl
Dither and hash functions

*/
#define MAGIC vec3(443.8975, 397.2973, 491.1871)

float grid_noise(vec2 p) {
  return fract(
    dot(
      p - vec2(0.5, 0.5),
      vec2(0.0625, .277777777777777777778) + 0.25
      )
    );
}

float dither_grad_noise(vec2 p) {
  return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

// float hash11(float p) {
//   p = fract(p * .1031);
//   p *= p + 33.33;
//   p *= p + p;
//   return fract(p);
// }

vec2 hash21(float p) {
  vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx+p3.yz)*p3.zy);
}

float texture_noise_64(vec2 p, sampler2D noise) {
  return texture2D(noise, p * 0.015625).r;
}

float timed_texture_noise_64(vec2 p, sampler2D noise) {
  vec2 dither = hash21(frameTimeCounter);
  return texture2D(noise, p * 0.015625 + dither).r;
}

//
// float timed_hash11(float p) {
//   p = fract((p + frameTimeCounter) * .1031);
//   p *= p + 33.33;
//   p *= p + p;
//   return fract(p);
// }

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float timed_hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx + frameTimeCounter) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

// vec2 hash22(vec2 p) {
//   vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
//   p3 += dot(p3, p3.yzx+33.33);
//   return fract((p3.xx+p3.yz)*p3.zy);
// }
//
// vec2 timed_hash22(vec2 p) {
//   vec3 p3 = fract(vec3(p.xyx + frameTimeCounter) * vec3(.1031, .1030, .0973));
//   p3 += dot(p3, p3.yzx + 33.33);
//   return fract((p3.xx + p3.yz) * p3.zy);
// }

float bayer2(vec2 a) {
  a = floor(a);
  return fract(dot(a, vec2(.5, a.y * .75)));
}

#define bayer4(a)   (bayer2(.5 * (a)) * .25+ bayer2(a))
#define bayer8(a)   (bayer4(.5 * (a)) * .25+ bayer2(a))
#define bayer16(a)  (bayer8(.5 * (a)) * .25+ bayer2(a))
//
// #define bayer64(a)  (bayer32(.5 * (a)) * .25+ bayer2(a))
// #define bayer128(a) (bayer64(.5 * (a)) * 0.25 + bayer2(a))
// #define bayer256(a) (bayer128(.5 * (a)) * 0.25 + bayer2(a))

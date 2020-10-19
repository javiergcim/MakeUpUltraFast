/* MakeUp Ultra Fast - dither.glsl
Dither functions

*/
#define MAGIC vec3(443.8975, 397.2973, 491.1871)

float timed_hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx * frameTimeCounter * .0001) * MAGIC);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

float grid_noise(vec2 p) {
  return fract(
    dot(
      p - vec2(0.5, 0.5),
      vec2(0.0625, .277777777777777777778) + 0.25
      )
    );
}

float dither_grad_noise(vec2 p){
		return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
	}

float texture_noise_32(vec2 p, sampler2D noise) {
		return texture2D(noise, p * 0.03125).r;
}

// float hash12() {
//   vec3 p3 = fract(vec3(gl_FragCoord.xyx) * MAGIC);
//   p3 += dot(p3, p3.yzx + 19.19);
//   return fract((p3.x + p3.y) * p3.z);
// }

// vec2 hash21(float p) {
// 	vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
// 	p3 += dot(p3, p3.yzx + 33.33);
//     return fract((p3.xx + p3.yz) * p3.zy);
// }
//
// vec2 hash22(vec2 p) {
// 	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
//   p3 += dot(p3, p3.yzx + 33.33);
//   return fract((p3.xx + p3.yz) * p3.zy);
// }
//
// vec2 timed_hash22(vec2 p) {
// 	vec3 p3 = fract(vec3(p.xyx * frameTimeCounter) * vec3(.1031, .1030, .0973));
//   p3 += dot(p3, p3.yzx + 33.33);
//   return fract((p3.xx + p3.yz) * p3.zy);
// }

//
// vec2 hash21(float p)
// {
// 	vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
// 	p3 += dot(p3, p3.yzx + 33.33);
//   return fract((p3.xx + p3.yz) * p3.zy);
// }

float bayer2(vec2 a) {
	a = floor(a);
	return fract(dot(a, vec2(.5, a.y * .75)));
}

#define bayer4(a)   (bayer2(.5 * (a)) * .25+ bayer2(a))
#define bayer8(a)   (bayer4(.5 * (a)) * .25+ bayer2(a))
#define bayer16(a)  (bayer8(.5 * (a)) * .25+ bayer2(a))
#define bayer32(a)  (bayer16(.5 * (a)) * .25+ bayer2(a))
// #define bayer64(a)  (bayer32(.5 * (a)) * .25+ bayer2(a))
// #define bayer128(a) (bayer64(.5 * (a)) * 0.25 + bayer2(a))
// #define bayer256(a) (bayer128(.5 * (a)) * 0.25 + bayer2(a))

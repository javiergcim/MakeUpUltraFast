/* MakeUp Ultra Fast - dither.glsl
Dither functions

*/
#define MAGIC vec3(443.8975,397.2973, 491.1871)

// float hash12()
// {
//   vec3 p3 = fract(vec3(gl_FragCoord.xyx) * MAGIC);
//   p3 += dot(p3, p3.yzx + 19.19);
//   return fract((p3.x + p3.y) * p3.z);
// }

float timed_hash12()
{
  vec3 p3 = fract(vec3(gl_FragCoord.xyx * frameTimeCounter * .0001) * MAGIC);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

float grid_noise() {
  return fract(
    dot(
      gl_FragCoord.xy - vec2(0.5, 0.5),
      vec2(0.0625, .277777777777777777778) + 0.25
      )
    );
}

// float bayer2(vec2 a){
// 	a = floor(a);
// 	return fract(dot(a, vec2(.5, a.y * .75)));
// }
//
// #define bayer4(a)   (bayer2(.5 * (a)) * .25+ bayer2(a))
// #define bayer8(a)   (bayer4(.5 * (a)) * .25+ bayer2(a))
// #define bayer16(a)  (bayer8(.5 * (a)) * .25+ bayer2(a))
// #define bayer32(a)  (bayer16(.5 * (a)) * .25+ bayer2(a))
// #define bayer64(a)  (bayer32(.5 * (a)) * .25+ bayer2(a))
// #define bayer128(a) (bayer64(.5 * (a)) * 0.25 + bayer2(a))
// #define bayer256(a) (bayer128(.5 * (a)) * 0.25 + bayer2(a))

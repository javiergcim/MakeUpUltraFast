/* MakeUp - dither.glsl
Dither and hash functions

*/

#define UI0 1597334673u
#define UI1 3812015801u
#define UI2 uvec2(UI0, UI1)
#define UI3 uvec3(UI0, UI1, 2798796415u)
#define UIF (1.0 / float(0xffffffffu))

float dither_grad_noise(vec2 p) {
  return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

float texture_noise_64(vec2 p, sampler2D noise) {
  return texture(noise, p * 0.015625).r;
}

float shifted_texture_noise_64(vec2 p, sampler2D noise) {
  float dither = texture(noise, p * 0.015625).r;
  return fract(frameTimeCounter * 7.0 + dither);
}

float timed_int_hash12(uvec2 x)
{
  x += uint(frameTimeCounter * 2400.0);
  uvec2 q = 1103515245u * ((x >> 1u) ^ (x.yx));
  uint n = 1103515245u * ((q.x) ^ (q.y >> 3u));
  return float(n) * (1.0 / float(0xffffffffu));
}

float int_hash12(uvec2 x)
{
  uvec2 q = 1103515245u * ((x >> 1u) ^ (x.yx));
  uint n = 1103515245u * ((q.x) ^ (q.y >> 3u));
  return float(n) * (1.0 / float(0xffffffffu));
}

vec2 timed_int_hash22(uvec2 q)
{
  q += uint(frameTimeCounter * 2400.0);
  q *= UI2;
  q = (q.x ^ q.y) * UI2;
  return vec2(q) * UIF;
}

vec2 int_hash22(uvec2 q)
{
  q *= UI2;
  q = (q.x ^ q.y) * UI2;
  return vec2(q) * UIF;
}

vec3 int_hash32(uvec2 q)
{
  uvec3 n = q.xyx * UI3;
  n = (n.x ^ n.y ^n.z) * UI3;
  return vec3(n) * UIF;
}

vec3 timed_int_hash32(uvec2 q)
{
  q += uvec2(frameTimeCounter * 2400.0);
  uvec3 n = q.xyx * UI3;
  n = (n.x ^ n.y ^n.z) * UI3;
  return vec3(n) * UIF;
}

float phi_noise(uvec2 uv)
{
  if(((uv.x ^ uv.y) & 4u) == 0u) uv = uv.yx;

  const uint r0 = 3242174893u;
  const uint r1 = 2447445397u;

  uint h = (uv.x * r0) + (uv.y * r1);

  uv = uv >> 2u;
  uint l = ((uv.x * r0) ^ (uv.y * r1)) * r1;

  return float(l + h) * (1.0 / 4294967296.0);
}

float shifted_phi_noise(uvec2 uv)
{
  if(((uv.x ^ uv.y) & 4u) == 0u) {
    uv = uv.yx;
  }

  const uint r0 = 3242174893u;
  const uint r1 = 2447445397u;

  uint h = (uv.x * r0) + (uv.y * r1);

  uv = uv >> 2u;
  uint l = ((uv.x * r0) ^ (uv.y * r1)) * r1;

  float dither = float(l + h) * (1.0 / 4294967296.0);
  return fract(frameTimeCounter * 7.0 + dither);
}

// float bayer2(vec2 a) {
//   a = floor(a);
//   return fract(dot(a, vec2(.5, a.y * .75)));
// }
//
// #define bayer4(a)   (bayer2(.5 * (a)) * .25+ bayer2(a))
// #define bayer8(a)   (bayer4(.5 * (a)) * .25+ bayer2(a))
// #define bayer16(a)  (bayer8(.5 * (a)) * .25+ bayer2(a))
// #define bayer32(a)  (bayer16(.5 * (a)) * .25+ bayer2(a))
// #define bayer64(a)  (bayer32(.5 * (a)) * .25+ bayer2(a))
// #define bayer128(a) (bayer64(.5 * (a)) * 0.25 + bayer2(a))
// #define bayer256(a) (bayer128(.5 * (a)) * 0.25 + bayer2(a))

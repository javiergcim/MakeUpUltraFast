/* MakeUp - dither.glsl
Dither and hash functions

*/

#define UI0 1597334673U
#define UI1 3812015801U
#define UI2 uvec2(UI0, UI1)
#define UI3 uvec3(UI0, UI1, 2798796415U)
#define UIF (1.0 / float(0xffffffffU))

// float hash12(vec2 p) {
//   vec3 p3 = fract(vec3(p.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   return fract((p3.x + p3.y) * p3.z);
// }

float hash12(vec2 p)
{
	uvec2 q = uvec2(ivec2(p)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	return float(n) * UIF;
}

// float timed_hash12(vec2 p) {
//   vec3 p3 = fract(vec3(p.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   return fract(0.3 * frame_mod + ((p3.x + p3.y) * p3.z));
// }

float timed_hash12(vec2 p)
{
	uvec2 q = uvec2(ivec2(p)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	return fract(0.3 * frame_mod + (float(n) * UIF));
}

float r_dither(vec2 frag) {
  return fract(dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float shifted_r_dither(vec2 frag) {
  return fract((0.7 * frame_mod) + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

// float eclectic_r_dither(vec2 frag) {
//   vec3 p3 = fract(vec3(frag.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.125;

//   return fract(p4 + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
// }

float eclectic_r_dither(vec2 frag) {
  uvec2 q = uvec2(ivec2(frag)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.125;

  return fract(p4 + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

// float shifted_eclectic_r_dither(vec2 frag) {
//   vec3 p3 = fract(vec3(frag.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.125;

//   return fract((0.7 * frame_mod) + p4 + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
// }

float shifted_eclectic_r_dither(vec2 frag) {
  uvec2 q = uvec2(ivec2(frag)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.125;

  return fract((0.7 * frame_mod) + p4 + dot(frag, vec2(0.75487766624669276, 0.569840290998)));
}

float dither17(vec2 pos) {
  return fract(dot(vec3(pos, 0.0), vec3(0.11764705882352941, 0.4117647058823529, 1.3529411764705883)));
}

float shifted_dither17(vec2 pos) {
  return fract((0.25 * frame_mod) + dot(vec3(pos, 0.0), vec3(0.11764705882352941, 0.4117647058823529, 1.3529411764705883)));
}

// float eclectic_dither17(vec2 frag) {
//   vec3 p3 = fract(vec3(frag.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.125;

//   return fract(p4 + dot(vec3(frag.xy, 0.0), vec3(2.0, 7.0, 23.0) / 17.0));
// }

float eclectic_dither17(vec2 frag) {
  uvec2 q = uvec2(ivec2(frag)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.125;

  return fract(p4 + dot(vec3(frag.xy, 0.0), vec3(2.0, 7.0, 23.0) / 17.0));
}

// float shifted_eclectic_dither17(vec2 frag) {
//   vec3 p3 = fract(vec3(frag.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.075;

//   return fract((0.3 * frame_mod) + p4 + dot(vec3(frag.xy, 0.0), vec3(2.0, 7.0, 23.0) / 17.0));
// }

float shifted_eclectic_dither17(vec2 frag) {
  uvec2 q = uvec2(ivec2(frag)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.075;

  return fract((0.3 * frame_mod) + p4 + dot(vec3(frag.xy, 0.0), vec3(2.0, 7.0, 23.0) / 17.0));
}

float dither_grad_noise(vec2 p) {
  return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

float shifted_dither_grad_noise(vec2 p) {
  return fract(0.3975 * frame_mod + (52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y)));
}

// float eclectic_dither(vec2 frag) {
//   vec3 p3 = fract(vec3(frag.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.14;

//   return fract(p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
// }

float eclectic_dither(vec2 frag) {
  uvec2 q = uvec2(ivec2(frag)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.14;

  return fract(p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
}

// float shifted_eclectic_dither(vec2 frag) {
//   vec3 p3 = fract(vec3(frag.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.14;

//   return fract((0.3975 * frame_mod) + p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
// }

float shifted_eclectic_dither(vec2 frag) {
  uvec2 q = uvec2(ivec2(frag)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.14;

  return fract((0.3975 * frame_mod) + p4 + (52.9829189 * fract(0.06711056 * frag.x + 0.00583715 * frag.y)));
}

float grid_noise(vec2 p) {
  return fract(
    dot(
      p - vec2(0.5, 0.5),
      vec2(0.0625, .277777777777777777778) + 0.25
      )
    );
}

float shifted_grid_noise(vec2 p) {
  return fract(0.4 * frame_mod +
    dot(
      p - vec2(0.5, 0.5),
      vec2(0.0625, .277777777777777777778) + 0.25
      )
    );
}

// float shifted_eclectic_grid_noise(vec2 p) {
//   vec3 p3 = fract(vec3(p.xyx) * .1031);
//   p3 += dot(p3, p3.yzx + 33.33);
//   float p4 = fract((p3.x + p3.y) * p3.z) * 0.125;
  
//   return fract(0.4 * frame_mod + p4 +
//     dot(
//       p - vec2(0.5, 0.5),
//       vec2(0.0625, .277777777777777777778) + 0.25
//       )
//     );
// }

float shifted_eclectic_grid_noise(vec2 p) {
  uvec2 q = uvec2(ivec2(p)) * UI2;
	uint n = (q.x ^ q.y) * UI0;
	float p4 = float(n) * UIF * 0.125;
  
  return fract(0.4 * frame_mod + p4 +
    dot(
      p - vec2(0.5, 0.5),
      vec2(0.0625, .277777777777777777778) + 0.25
      )
    );
}

// float texture_noise_64(vec2 p, sampler2D noise) {
//   return texture(noise, p * 0.015625).r;
// }

// float shifted_texture_noise_64(vec2 p, sampler2D noise) {
//   float dither = texture(noise, p * 0.015625).r;
//   return fract(0.6 * frame_mod + dither);
// }

float phi_noise(vec2 uv_f)
{
  uvec2 uv = uvec2(uv_f);
  
  if (((uv.x ^ uv.y) & 4u) == 0u) uv = uv.yx;

  const uint r0 = 3242174893u;
  const uint r1 = 2447445397u;

  uint h = (uv.x * r0) + (uv.y * r1);

  uv = uv >> 2u;
  uint l = ((uv.x * r0) ^ (uv.y * r1)) * r1;

  return float(l + h) * 2.3283064365386963e-10;
}

float shifted_phi_noise(vec2 uv_f)
{
  uvec2 uv = uvec2(uv_f);

  if (((uv.x ^ uv.y) & 4u) == 0u) uv = uv.yx;

  const uint r0 = 3242174893u;
  const uint r1 = 2447445397u;

  uint h = (uv.x * r0) + (uv.y * r1);

  uv = uv >> 2u;
  uint l = ((uv.x * r0) ^ (uv.y * r1)) * r1;

  return fract(0.7 * frame_mod + (float(l + h) * 2.3283064365386963e-10));
}

float smooth_noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
	
	  vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(hash12(i + vec2(0.0,0.0)), 
                   hash12(i + vec2(1.0,0.0)), u.x),
               mix(hash12(i + vec2(0.0,1.0)), 
                   hash12(i + vec2(1.0,1.0)), u.x), u.y);
}

float pseudo_perlin(vec2 uv) {
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );

    float f  = 0.5000 * smooth_noise( uv ); uv = m*uv;
		f += 0.2500 * smooth_noise( uv ); uv = m * uv;
		f += 0.1250 * smooth_noise( uv ); uv = m * uv;
		f += 0.0625 * smooth_noise( uv ); uv = m * uv;
    f += 0.03125 * smooth_noise( uv ); uv = m * uv;
    f += 0.015625 * smooth_noise( uv ); uv = m * uv;
    f += 0.0078125 * smooth_noise( uv ); uv = m * uv;

    return f;
}

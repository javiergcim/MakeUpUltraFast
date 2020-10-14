#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Tonemap

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;

#if AO == 1
  uniform float aspectRatio;
  uniform mat4 gbufferProjection;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils_nether.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"
#include "/lib/depth.glsl"

#if AO == 1
  #include "/lib/dither.glsl"
  #include "/lib/ao.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex0, texcoord);

  #if AO == 1
    // AO distance attenuation
    float d = texture2D(depthtex0, texcoord).r;
    float ao_att = sqrt(ld(d));
    float final_ao = mix(dbao(depthtex0), 1.0, ao_att);
    block_color *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
  #endif

  // x: Block, y: Sky ---
  float candle_bright = (eyeBrightnessSmooth.x / 240.0) * .1;
  float exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );
  float exposure =
    ((eyeBrightnessSmooth.y / 240.0) * exposure_coef) + candle_bright;

  // Map from 1.0 - 0.0 to 1.0 - 3.0
  exposure = (exposure * -2.0) + 3.0;

  // Niebla bajo el agua
  #if AO == 0
    float d = texture2D(depthtex0, texcoord).r;
  #endif
  // Niebla
  if (isEyeInWater == 0) {
    block_color = mix(
      block_color,
      mix(gl_Fog.color * .5, vec4(1.0), .04),
      sqrt(ld(d))
    );
  }
  else if (isEyeInWater == 1) {
    block_color.rgb = mix(
      block_color.rgb,
      skyColor * .5 * ((eyeBrightnessSmooth.y * .8 + 48) / 240.0),
      sqrt(ld(d))
      );
  } else if (isEyeInWater == 2) {
    block_color = mix(
      block_color,
      vec4(1.0, .1, 0.0, 1.0),
      sqrt(ld(d))
      );
  }

  block_color.rgb *= exposure;
  #if TONEMAP == 0
    block_color.rgb = tonemap(block_color.rgb);
  #elif TONEMAP == 1
    block_color.rgb = aces_tonemap(block_color.rgb);
  #endif

  // gl_FragData[1] = vec4(0.0);  // ¿Performance?
  gl_FragData[2] = block_color;
}

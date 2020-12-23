#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float rainStrength;

#if MAKEUP_COLOR == 0
  uniform vec3 skyColor;
#elif MAKEUP_COLOR == 1
  uniform int current_hour_floor;
  uniform int current_hour_ceil;
  uniform float current_hour_fract;
#endif

#if AO == 1
  uniform sampler2D colortex5;
  uniform float inv_aspect_ratio;
  uniform mat4 gbufferProjection;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/depth.glsl"

#if MAKEUP_COLOR == 1
  #include "/lib/luma.glsl"
#endif

#if AO == 1
  #include "/lib/dither.glsl"
  #include "/lib/ao.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex0, texcoord);
  float d = texture2D(depthtex0, texcoord).r;
  #if AO == 1
    // AO distance attenuation
    float fog_density_coeff = mix(
      fog_density[current_hour_floor],
      fog_density[current_hour_ceil],
      current_hour_fract
      );

    float ao_att = pow(
      clamp(ld(d), 0.0, 1.0),
      mix(fog_density_coeff * .5, .25, rainStrength)
    );

    float final_ao = mix(dbao(), 1.0, ao_att);
    block_color.rgb *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
    // block_color = vec4(vec3(ld(d)), 1.0);
  #endif

  #if MAKEUP_COLOR == 0
    vec3 hi_sky_color = skyColor;
  #elif MAKEUP_COLOR == 1
    vec3 hi_sky_color = mix(
      hi_sky_color_array[current_hour_floor],
      hi_sky_color_array[current_hour_ceil],
      current_hour_fract
    );

    hi_sky_color = mix(
      hi_sky_color,
      HI_SKY_RAIN_COLOR * luma(hi_sky_color),
      rainStrength
    );
  #endif

  // Niebla
  if (isEyeInWater == 1) {
    block_color.rgb = mix(
      block_color.rgb,
      hi_sky_color * .5 * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667),
      sqrt(ld(d))
      );
  } else if (isEyeInWater == 2) {
    block_color = mix(
      block_color,
      vec4(1.0, .1, 0.0, 1.0),
      sqrt(ld(d))
      );
  }
  /* DRAWBUFFERS:012 */
  gl_FragData[1] = vec4(block_color.rgb, d);
}

#version 120
/* MakeUp - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#define SET_FOG_COLOR

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform int isEyeInWater;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform int frame_mod;
uniform float rainStrength;
uniform ivec2 eyeBrightnessSmooth;

// Varyings (per thread shared variables)
varying vec3 up_vec;  // Flat
varying vec4 star_data;

#include "/lib/dither.glsl"
#include "/lib/luma.glsl"

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(star_data.rgb, 1.0);
  // vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);
  #if AA_TYPE > 0
    float dither = timed_hash12(gl_FragCoord.xy);
  #else
    float dither = hash12(gl_FragCoord.xy);
  #endif

  dither = (dither - .5) * 0.0625;

  vec3 hi_sky_color = day_blend(
    HI_MIDDLE_COLOR,
    HI_DAY_COLOR,
    HI_NIGHT_COLOR
    );

  hi_sky_color = mix(
    hi_sky_color,
    HI_SKY_RAIN_COLOR * luma(hi_sky_color),
    rainStrength
  );

  vec3 low_sky_color = day_blend(
    LOW_MIDDLE_COLOR,
    LOW_DAY_COLOR,
    LOW_NIGHT_COLOR
    );

  low_sky_color = mix(
    low_sky_color,
    LOW_SKY_RAIN_COLOR * luma(low_sky_color),
    rainStrength
  );

  vec4 fragpos = gbufferProjectionInverse *
  (
    vec4(
      gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
      gl_FragCoord.z,
      1.0
    ) * 2.0 - 1.0
  );
  vec3 nfragpos = normalize(fragpos.xyz);
  float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
  vec3 background_color = mix(
    low_sky_color,
    hi_sky_color,
    sqrt(n_u)
  );

  if (star_data.a < 0.9) {
    block_color.rgb = background_color;
  }

  #include "/src/writebuffers.glsl"

}

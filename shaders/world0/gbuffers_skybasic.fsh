#version 120
/* MakeUp Ultra Fast - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
varying vec3 up_vec;
varying vec4 star_data;

// 'Global' constants from system
uniform int isEyeInWater;

#if MAKEUP_COLOR == 1
  uniform int current_hour_floor;
  uniform int current_hour_ceil;
  uniform float current_hour_fract;
#else
  uniform vec3 skyColor;
  uniform vec3 fogColor;
#endif

uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float frameTimeCounter;
uniform float rainStrength;

#include "/lib/dither.glsl"
#include "/lib/luma.glsl"

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(star_data.rgb, 1.0);
  float dither;

  if (star_data.a < .9) {
    #if AA_TYPE == 1 || AA_TYPE == 2
      dither = timed_hash12(gl_FragCoord.xy);
    #else
      dither = hash12(gl_FragCoord.xy);
    #endif
    dither = (dither - .5) * 0.0625;

    #if MAKEUP_COLOR == 1
      // vec3 hi_sky_color = mix(
      //   hi_sky_color_array[current_hour_floor],
      //   hi_sky_color_array[current_hour_ceil],
      //   current_hour_fract
      // );
      vec3 hi_sky_color =
        texture2D(gaux3, vec2(0.5, (current_hour * .04) + .02)).rgb;
      // vec3 hi_sky_color = vec3(1.0, 0.0, 0.0);

      hi_sky_color = mix(
        hi_sky_color,
        HI_SKY_RAIN_COLOR * luma(hi_sky_color),
        rainStrength
      );

      // vec3 low_sky_color = mix(
      //   low_sky_color_array[current_hour_floor],
      //   low_sky_color_array[current_hour_ceil],
      //   current_hour_fract
      // );
      vec3 low_sky_color =
        texture2D(gaux3, vec2(0.833334, (current_hour * .04) + .02)).rgb;
      // vec3 low_sky_color = vec3(0.0, 1.0, 0.0);

      low_sky_color = mix(
        low_sky_color,
        LOW_SKY_RAIN_COLOR * luma(low_sky_color),
        rainStrength
      );

      float sky_gradient = .75;
    #else
      vec3 hi_sky_color = skyColor;
      vec3 low_sky_color = fogColor;
      float sky_gradient = .25;
    #endif

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
    block_color.rgb = mix(
      low_sky_color,
      hi_sky_color,
      pow(n_u, sky_gradient)
    );
  }

  #include "/src/writebuffers.glsl"
}

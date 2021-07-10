#version 120
/* MakeUp - composite.fsh
Render: Bloom and volumetric light

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

#if defined VOL_LIGHT && defined SHADOW_CASTING
  uniform float rainStrength;
  uniform int isEyeInWater;
#endif

#if defined BLOOM || (defined VOL_LIGHT && defined SHADOW_CASTING)
  uniform float current_hour_fract;
  uniform int current_hour_floor;
  uniform int current_hour_ceil;
  uniform ivec2 eyeBrightnessSmooth;
#endif

#if defined BLOOM || (defined VOL_LIGHT && defined SHADOW_CASTING)
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if defined VOL_LIGHT && defined SHADOW_CASTING
  varying vec3 vol_light_color;
#endif

#ifdef BLOOM
  varying float exposure;  // Flat
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  #ifdef BLOOM
    // Exposure
    float candle_bright = eyeBrightnessSmooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)
    float exposure_coef =
      mix(
        ambient_exposure[current_hour_floor],
        ambient_exposure[current_hour_ceil],
        current_hour_fract
      );
    exposure =
      ((eyeBrightnessSmooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

    // Map from 1.0 - 0.0 to 1.0 - 3.4
    exposure = (exposure * -2.4) + 3.4;
  #endif

  #if defined VOL_LIGHT && defined SHADOW_CASTING
    float vol_attenuation;
    if (isEyeInWater == 0) {
      vol_attenuation = 1.0;
    } else {
      vol_attenuation = 0.1 + (eyeBrightnessSmooth.y * 0.002);
    }

    vol_light_color = day_blend(
      LOW_MIDDLE_COLOR,
      LOW_DAY_COLOR,
      LOW_NIGHT_COLOR
      ) * vol_attenuation;
  #endif
}

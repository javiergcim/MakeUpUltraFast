/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform float current_hour_fract;
uniform int current_hour_floor;
uniform int current_hour_ceil;

#if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
  uniform float rainStrength;
  uniform int isEyeInWater;
#endif

#if defined BLOOM || (defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER)
  uniform ivec2 eyeBrightnessSmooth;
#endif

varying vec2 texcoord;
varying float exposure_coef;  // Flat

#if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
  varying vec3 vol_light_color;  // Flat
#endif

#ifdef BLOOM
  varying float exposure;  // Flat
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );

  #ifdef BLOOM
    // Exposure
    float candle_bright = eyeBrightnessSmooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)

    exposure =
      ((eyeBrightnessSmooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

    // Map from 1.0 - 0.0 to 1.0 - 3.4
    exposure = (exposure * -2.4) + 3.4;
  #endif

  #if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
    float vol_attenuation;
    if (isEyeInWater == 0) {
      vol_attenuation = 1.0;
    } else {
      vol_attenuation = 0.1 + (eyeBrightnessSmooth.y * 0.002);
    }

    vol_light_color = day_blend(
      AMBIENT_MIDDLE_COLOR,
      AMBIENT_DAY_COLOR,
      AMBIENT_NIGHT_COLOR
      ) * 1.2 * vol_attenuation;
  #endif
}

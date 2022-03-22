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

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  uniform float rainStrength;
  uniform int isEyeInWater;
#endif

#if defined BLOOM || (VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER))
  uniform ivec2 eyeBrightnessSmooth;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
  uniform float light_mix; 
  uniform vec3 sunPosition;
  uniform vec3 moonPosition;
  uniform mat4 gbufferProjection;
#endif

in vec3 vaPosition;

out vec2 texcoord;
flat out float exposure_coef;  // Flat

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  flat out vec3 vol_light_color;  // Flat
#endif

#ifdef BLOOM
  flat out float exposure;  // Flat
#endif

#if VOL_LIGHT == 1 && !defined NETHER
  flat out vec2 lightpos;  // Flat
  flat out vec3 astro_pos;  // Flat
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);
  texcoord = vaPosition.xy;

  #if defined BLOOM || (VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER))
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
  #endif

  exposure_coef = day_blend_float(
    EXPOSURE_MIDDLE,
    EXPOSURE_DAY,
    EXPOSURE_NIGHT
  );

  #ifdef BLOOM
    // Exposure
    float candle_bright = eye_bright_smooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)

    exposure =
      ((eye_bright_smooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

    // Map from 1.0 - 0.0 to 1.0 - 3.4
    exposure = (exposure * -2.4) + 3.4;
  #endif

  #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    float vol_attenuation;
    if (isEyeInWater == 0) {
      vol_attenuation = 1.0;
    } else {
      vol_attenuation = 0.1 + (eye_bright_smooth.y * 0.002);
    }

    vol_light_color = day_blend(
      AMBIENT_MIDDLE_COLOR,
      AMBIENT_DAY_COLOR,
      AMBIENT_NIGHT_COLOR
      ) * 1.2 * vol_attenuation;
  #endif

  #if VOL_LIGHT == 1 && !defined NETHER
    astro_pos = sunPosition * step(0.5, light_mix) * 2.0 + moonPosition;
    vec4 tpos = vec4(astro_pos, 1.0) * gbufferProjection;
    tpos = vec4(tpos.xyz / tpos.w, 1.0);
    vec2 pos1 = tpos.xy / tpos.z;
    lightpos = pos1 * 0.5 + 0.5;
  #endif
}

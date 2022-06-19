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

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 gbufferProjectionInverse;
#endif

uniform sampler2D colortex1;
uniform sampler2D gaux3;
uniform float viewWidth;
uniform float frameTime;
uniform float rainStrength;

varying vec2 texcoord;
// varying float exposure_coef;  // Flat
varying vec3 direct_light_color;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  varying vec3 vol_light_color;  // Flat
#endif

// #ifdef BLOOM
  varying float exposure;  // Flat
// #endif

#if VOL_LIGHT == 1 && !defined NETHER
  varying vec2 lightpos;  // Flat
  varying vec3 astro_pos;  // Flat
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  varying mat4 modeli_times_projectioni;
#endif

// #if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
  #include "/lib/luma.glsl"
// #endif

const bool colortex1MipmapEnabled = true;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  #if defined BLOOM || (VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER))
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
  #endif

  direct_light_color = day_blend(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR
  );

  direct_light_color = mix(
    direct_light_color,
    HI_SKY_RAIN_COLOR * luma(direct_light_color),
    rainStrength
  );

  // #ifdef BLOOM
    // Exposure
    #if !defined UNKNOWN_DIM
      exposure = luma(texture2DLod(colortex1, vec2(0.5), log2(viewWidth * 0.3)).rgb);
      float prev_exposure = texture2D(gaux3, vec2(0.5)).r;

      exposure = (exp(-exposure * 4.9) * 3.2) + 0.6;
      exposure = mix(exposure, prev_exposure, exp(-frameTime * 1.25));

    #else
      exposure = 1.0;
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

  #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    modeli_times_projectioni = gbufferModelViewInverse * gbufferProjectionInverse;
  #endif
}

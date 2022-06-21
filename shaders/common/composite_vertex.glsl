/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
#if !defined NETHER
  uniform int worldTime;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
  #include "/iris_uniforms/light_mix.glsl"
#endif

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform float rainStrength;
uniform ivec2 eyeBrightnessSmooth;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  uniform int isEyeInWater;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
  // uniform float light_mix; 
  uniform vec3 sunPosition;
  uniform vec3 moonPosition;
  uniform mat4 gbufferProjection;
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 gbufferProjectionInverse;
#endif

#if (!defined MC_GL_VENDOR_MESA || !defined MC_GL_RENDERER_MESA) && !defined MC_GL_RENDERER_INTEL && !defined SIMPLE_AUTOEXP
  uniform sampler2D colortex1;
  uniform sampler2D gaux3;
  uniform float viewWidth;
  uniform float frameTime;
#endif

varying vec2 texcoord;
varying vec3 direct_light_color;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  varying vec3 vol_light_color;  // Flat
#endif

varying float exposure;  // Flat

#if VOL_LIGHT == 1 && !defined NETHER
  varying vec2 lightpos;  // Flat
  varying vec3 astro_pos;  // Flat
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  varying mat4 modeli_times_projectioni;
#endif

#include "/lib/luma.glsl"

#if (!defined MC_GL_VENDOR_MESA || !defined MC_GL_RENDERER_MESA) && !defined MC_GL_RENDERER_INTEL && !defined SIMPLE_AUTOEXP
  const bool colortex1MipmapEnabled = true;
#endif

void main() {
  // Pseudo-uniforms section
  #if !defined NETHER
    float day_moment = day_moment();
    float day_mixer = day_mixer(day_moment);
    float night_mixer = night_mixer(day_moment);
  #endif
  #if VOL_LIGHT == 1 && !defined NETHER
    float light_mix = light_mix();
  #endif

  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

  direct_light_color = day_blend(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR,
    day_mixer,
    night_mixer,
    day_moment
  );

  direct_light_color = mix(
    direct_light_color,
    HI_SKY_RAIN_COLOR * luma(direct_light_color),
    rainStrength
  );

  // Exposure
  #if !defined UNKNOWN_DIM
    #if (defined MC_GL_VENDOR_MESA && defined MC_GL_RENDERER_MESA) || defined MC_GL_RENDERER_INTEL || defined SIMPLE_AUTOEXP

      float exposure_coef = day_blend_float(
        EXPOSURE_MIDDLE,
        EXPOSURE_DAY,
        EXPOSURE_NIGHT,
        day_mixer,
        night_mixer,
        day_moment
      );

      float candle_bright = eye_bright_smooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)

      exposure =
        ((eye_bright_smooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

      // Map from 1.0 - 0.0 to 1.0 - 3.4
      exposure = (exposure * -2.4) + 3.4;
    #else
      exposure = luma(texture2DLod(colortex1, vec2(0.5), log2(viewWidth * 0.3)).rgb);
      float prev_exposure = texture2D(gaux3, vec2(0.5)).r;

      exposure = (exp(-exposure * 4.9) * 3.0) + 0.6;
      exposure = mix(exposure, prev_exposure, exp(-frameTime * 1.25));
    #endif
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
      AMBIENT_NIGHT_COLOR,
      day_mixer,
      night_mixer,
      day_moment
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

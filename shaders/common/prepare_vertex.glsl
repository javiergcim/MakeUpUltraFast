/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform mat4 gbufferModelView;
uniform float rainStrength;

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#include "/lib/luma.glsl"

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

  #ifdef UNKNOWN_DIM
    hi_sky_color = skyColor;
    low_sky_color = fogColor;
  #else
    hi_sky_color = day_blend(
      ZENITH_SUNSET_COLOR,
      ZENITH_DAY_COLOR,
      ZENITH_NIGHT_COLOR
    );

    hi_sky_color = mix(
      hi_sky_color,
      ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color),
      rainStrength
    );

    low_sky_color = day_blend(
      HORIZON_SUNSET_COLOR,
      HORIZON_DAY_COLOR,
      HORIZON_NIGHT_COLOR
    );

    low_sky_color = mix(
      low_sky_color,
      HORIZON_SKY_RAIN_COLOR * luma(low_sky_color),
      rainStrength
    );
  #endif

  up_vec = normalize(gbufferModelView[1].xyz);
}

#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  tint_color = gl_Color;

  sky_luma_correction = luma(day_blend(
    LIGHT_SUNSET_COLOR,
    LIGHT_DAY_COLOR,
    LIGHT_NIGHT_COLOR
  ));

  #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    sky_luma_correction = 3.5 / ((sky_luma_correction * -2.5) + 3.5);
  #else
    sky_luma_correction = 1.5 / ((sky_luma_correction * -2.5) + 3.5);
  #endif

  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  
  #if AA_TYPE > 0
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif
}

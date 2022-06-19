#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float rainStrength;

varying vec4 tint_color;
varying vec2 texcoord;
varying vec3 basic_light;

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  tint_color = gl_Color;

  // vec2 lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * 1.0323886639676114;

  // vec2 basic_light_2 = (max(lmcoord, vec2(0.065)) - vec2(0.065)) * 1.06951871657754;

  basic_light = day_blend(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR
  );

  basic_light = mix(
    basic_light,
    HI_SKY_RAIN_COLOR * luma(basic_light),
    rainStrength
  );

  vec2 illumination = (max(lmcoord, vec2(0.065)) - vec2(0.065)) * 1.06951871657754;

  #if defined UNKNOWN_DIM
    vec3 candle_color =
      CANDLE_BASELIGHT * ((illumination.x * illumination.x) + pow(illumination.x * 1.205, 6.0)) * 2.75;
  #else
    vec3 candle_color =
      CANDLE_BASELIGHT * ((illumination.x * illumination.x) + pow(illumination.x * 1.165, 6.0));
  #endif

  basic_light += candle_color;
}

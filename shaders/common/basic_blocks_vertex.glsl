#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int worldTime;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

#include "/iris_uniforms/pixel_size_x.glsl"
#include "/iris_uniforms/pixel_size_y.glsl"
#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/taa_offset.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform float rainStrength;

varying vec4 tint_color;
varying vec2 texcoord;
varying vec3 basic_light;

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#if AA_TYPE > 0
  // #include "/src/taa_offset.glsl"
#endif

void main() {
  // Pseudo-uniforms section
  float day_moment = day_moment();
  float day_mixer = day_mixer(day_moment);
  float night_mixer = night_mixer(day_moment);
  #if AA_TYPE > 0
    int frame_mod = frame_mod();
    vec2 pixel_size = vec2(pixel_size_x(), pixel_size_y());
    vec2 taa_offset = taa_offset(frame_mod, pixel_size);
  #endif
   
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  tint_color = gl_Color;

  basic_light = day_blend(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR,
    day_mixer,
    night_mixer,
    day_moment
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

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

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/luma.glsl"

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
  
  texcoord = gl_MultiTexCoord0.xy;
  tint_color = gl_Color;

  sky_luma_correction = luma(day_blend(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR,
    day_mixer,
    night_mixer,
    day_moment
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

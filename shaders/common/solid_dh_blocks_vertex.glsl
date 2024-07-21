#include "/lib/config.glsl"

#if defined THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 dhProjection;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float light_mix;
uniform float far;
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;

#ifdef DISTANT_HORIZONS
  uniform int dhRenderDistance;
#endif

#ifdef UNKNOWN_DIM
  uniform sampler2D lightmap;
#endif

varying vec2 texcoord;
varying vec4 tint_color;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying vec4 position;
varying float frog_adjust;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"

void main() {
  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
  vec3 hi_sky_color;
  vec3 low_sky_color;

  #include "/src/basiccoords_vertex_dh.glsl"
  #include "/src/position_vertex_dh.glsl"
  #include "/src/sky_color_vertex.glsl"
  #include "/src/light_vertex_dh.glsl"
}

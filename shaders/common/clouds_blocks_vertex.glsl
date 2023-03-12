#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;

#if defined SHADOW_CASTING && !defined NETHER
  uniform mat4 gbufferModelViewInverse;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
  uniform mat4 gbufferModelView;
#endif

varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
  varying vec3 up_vec;
  varying vec3 hi_sky_color;
  varying vec3 low_sky_color;
#endif

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  tint_color = gl_Color;

  #if V_CLOUDS == 0 || defined UNKNOWN_DIM
    up_vec = normalize(gbufferModelView[1].xyz);
    #include "/src/sky_color_vertex.glsl"
  #endif


  #include "/src/position_vertex.glsl"
  #include "/src/cloudfog_vertex.glsl"
}

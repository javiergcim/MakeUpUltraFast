#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform mat4 gbufferProjectionInverse;

#if defined SHADOW_CASTING && !defined NETHER
  uniform mat4 gbufferModelViewInverse;
#endif

varying vec2 texcoord;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

  #include "/src/position_vertex.glsl"
}
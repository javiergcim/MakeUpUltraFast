#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform float rainStrength;

varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  tint_color = gl_Color;
  #include "/src/position_vertex.glsl"
  #include "/src/cloudfog_vertex.glsl"
}

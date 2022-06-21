#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int frameCounter;

#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/taa_offset.glsl"

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
  // Pseudo-uniforms section
  #if AA_TYPE > 0
    int frame_mod = frame_mod();
    vec2 taa_offset = taa_offset(frame_mod);
  #endif

  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  tint_color = gl_Color;
  #include "/src/position_vertex.glsl"
  #include "/src/cloudfog_vertex.glsl"
}

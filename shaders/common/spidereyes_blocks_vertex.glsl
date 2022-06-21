#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int frameCounter;

#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/taa_offset.glsl"

/* Config, uniforms, ins, outs */
varying vec2 texcoord;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  // Pseudo-uniforms section
  #if AA_TYPE > 0
    int frame_mod = frame_mod();
    vec2 taa_offset = taa_offset(frame_mod);
  #endif
  
  texcoord = gl_MultiTexCoord0.xy;

  #include "/src/position_vertex.glsl"
}
#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int frameCounter;

#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/taa_offset.glsl"

/* Config, uniforms, ins, outs */
// uniform vec3 chunkOffset;
// uniform mat4 modelViewMatrix;
// uniform mat4 projectionMatrix;

varying vec2 texcoord;
varying float var_fog_frag_coord;

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

  // #include "/src/position_vertex.glsl"
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  gl_FogFragCoord = length(gl_Position.xyz);
}
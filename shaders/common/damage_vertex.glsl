#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

varying vec2 texcoord;
varying float var_fog_frag_coord;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = gl_MultiTexCoord0.xy;

  #include "/src/position_vertex.glsl"
}
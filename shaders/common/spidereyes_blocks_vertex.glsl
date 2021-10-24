#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 vaUV0;  // Texture coordinates
in vec3 vaPosition;

out vec2 texcoord;
out float var_fog_frag_coord;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = vaUV0;

  #include "/src/position_vertex.glsl"
}
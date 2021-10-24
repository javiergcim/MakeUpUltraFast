#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix = mat4(1.0);
uniform mat4 gbufferModelViewInverse;

in vec2 vaUV0;  // Texture coordinates
in vec4 vaColor;
in vec3 vaPosition;

out vec2 texcoord;
out vec4 tint_color;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"

  tint_color = vaColor;
}

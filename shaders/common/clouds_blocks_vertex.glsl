#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform float rainStrength;
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 vaUV0;  // Texture coordinates
in vec4 vaColor;
in vec3 vaPosition;
in vec3 vaNormal;

out vec2 texcoord;
out vec4 tint_color;
out float frog_adjust;
out float var_fog_frag_coord;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  texcoord = vaUV0;
  tint_color = vaColor;
  #include "/src/position_vertex.glsl"
  #include "/src/cloudfog_vertex.glsl"
}

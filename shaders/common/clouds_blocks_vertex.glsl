#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
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

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

varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying float var_fog_frag_coord;

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

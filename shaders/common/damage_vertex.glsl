#include "/lib/config.glsl"

uniform mat4 gbufferProjectionInverse;

varying vec2 texcoord;
varying float var_fog_frag_coord;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  vec3 viewPos = gl_Position.xyz / gl_Position.w;
  vec4 homopos = gbufferProjectionInverse * vec4(viewPos, 1.0);
  viewPos = homopos.xyz / homopos.w;
  gl_FogFragCoord = length(viewPos.xyz);
}
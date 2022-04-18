#include "/lib/config.glsl"

varying vec4 tint_color;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  tint_color = gl_Color;
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  #if AA_TYPE == 1
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif
}

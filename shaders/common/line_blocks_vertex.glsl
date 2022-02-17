#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

varying vec4 tint_color;

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

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

/* Config, uniforms, ins, outs */
#define NO_SHADOWS

#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

varying vec4 tint_color;

void main() {
  vec4 block_color = tint_color;

  #include "/src/writebuffers.glsl"
}

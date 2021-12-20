#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
varying vec4 tint_color;
varying vec2 texcoord;
varying float basic_light;

void main() {
  vec4 block_color = tint_color;

  block_color.rgb *= basic_light;

  #include "/src/writebuffers.glsl"
}

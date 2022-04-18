/* Exits */
out vec4 outColor0;

/* Config, uniforms, ins, outs */
#define NO_SHADOWS

#include "/lib/config.glsl"

in vec4 tint_color;

void main() {
  vec4 block_color = tint_color;

  #include "/src/writebuffers.glsl"
}

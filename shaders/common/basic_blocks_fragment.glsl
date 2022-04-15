/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform float alphaTestRef;

in vec4 tint_color;
in vec2 texcoord;
in float basic_light;

void main() {
  vec4 block_color = tint_color;

  block_color.rgb *= basic_light;

  if(block_color.a < alphaTestRef) discard;  // Full transparency
  #include "/src/writebuffers.glsl"
}

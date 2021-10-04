/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform sampler2D gtexture;
uniform float alphaTestRef;

in vec2 texcoord;
in vec4 tint_color;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture(gtexture, texcoord) * tint_color;

  if(block_color.a < alphaTestRef) discard;
  #include "/src/writebuffers.glsl"
}
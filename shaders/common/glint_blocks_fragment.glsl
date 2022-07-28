#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform sampler2D tex;

varying vec2 texcoord;
varying vec4 tint_color;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord) * tint_color * 0.5;

  #include "/src/writebuffers.glsl"
}
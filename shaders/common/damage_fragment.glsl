/* Exits */
#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform sampler2D tex;

varying vec2 texcoord;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord);

  #include "/src/writebuffers.glsl"
}

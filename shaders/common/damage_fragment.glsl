/* Exits */
#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform sampler2D tex;

in vec2 texcoord;
in float var_fog_frag_coord;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord);

  #include "/src/writebuffers.glsl"
}

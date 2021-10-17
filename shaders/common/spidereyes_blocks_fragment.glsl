#include "/lib/config.glsl"

uniform sampler2D tex;

/* Config, uniforms, ins, outs */
varying vec2 texcoord;
varying float var_fog_frag_coord;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord);

  #include "/src/writebuffers.glsl"
}

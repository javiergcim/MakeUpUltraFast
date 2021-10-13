/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
in vec2 texcoord;
out float var_fog_frag_coord;

uniform sampler2D tex;
uniform float alphaTestRef;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord);

  if(block_color.a < alphaTestRef) discard;
  #include "/src/writebuffers.glsl"
}

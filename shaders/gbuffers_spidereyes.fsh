#version 120
/* MakeUp Ultra Fast - gbuffers_spidereyes.fsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Varyings (per thread shared variables)
varying vec2 texcoord;

// 'Global' constants from system
uniform sampler2D texture;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;
}

#version 120
/* MakeUp Ultra Fast - gbuffers_spidereyes.fsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// Varyings (per thread shared variables)
varying vec4 texcoord;

// 'Global' constants from system
uniform sampler2D texture;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord.xy);

  gl_FragData[0] = block_color;
  gl_FragData[1] = vec4(0.0);  // Not needed. Performance trick
  gl_FragData[5] = block_color;
}

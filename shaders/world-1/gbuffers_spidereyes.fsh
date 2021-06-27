#version 120
/* MakeUp - gbuffers_spidereyes.fsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;

// Varyings (per thread shared variables)
varying vec2 texcoord;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord);

  #include "/src/writebuffers.glsl"
}

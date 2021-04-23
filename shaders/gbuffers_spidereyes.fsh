#version 130
/* MakeUp - gbuffers_spidereyes.fsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
in vec2 texcoord;

// 'Global' constants from system
uniform sampler2D tex;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture(tex, texcoord);

  #include "/src/writebuffers.glsl"
}

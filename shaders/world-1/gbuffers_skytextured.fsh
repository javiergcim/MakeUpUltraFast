#version 130
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

in vec2 texcoord;
in vec4 tint_color;

// uniform sampler2D tex;

void main() {
  // Toma el color puro del bloque
  // vec4 block_color = texture(tex, texcoord) * tint_color;
  vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);

  #include "/src/writebuffers.glsl"
}

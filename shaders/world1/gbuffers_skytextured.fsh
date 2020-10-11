#version 120
/* MakeUp Ultra Fast - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"

varying vec2 texcoord;
varying vec4 tint_color;

uniform sampler2D texture;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord) * tint_color;

  #include "/src/writebuffers.glsl"
}

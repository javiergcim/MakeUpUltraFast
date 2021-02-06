#version 130
/* MakeUp Ultra Fast - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;

uniform sampler2D tex;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture(tex, texcoord) * tint_color;
  block_color.rgb *= sky_luma_correction;
  // block_color.rgb = block_color.rgb * block_color.a;

  #include "/src/writebuffers.glsl"
}

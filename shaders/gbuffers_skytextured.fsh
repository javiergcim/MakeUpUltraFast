#version 130
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;

// Varyings (per thread shared variables)
in vec2 texcoord;
in vec4 tint_color;
flat in float sky_luma_correction;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture(tex, texcoord) * tint_color;
  block_color.rgb *= sky_luma_correction;

  #include "/src/writebuffers.glsl"
}

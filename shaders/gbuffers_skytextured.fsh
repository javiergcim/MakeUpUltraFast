#version 120
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;
flat varying float sky_luma_correction;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord) * tint_color;
  block_color.rgb *= sky_luma_correction;

  #include "/src/writebuffers.glsl"
}

#version 130
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

in vec2 texcoord;
in vec4 tint_color;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(HI_DAY_COLOR, 1.0);

  #include "/src/writebuffers.glsl"
}

#version 120
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS
#define SET_FOG_COLOR

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

varying vec2 texcoord;
varying vec4 tint_color;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(HI_DAY_COLOR, 1.0);
  vec3 background_color = HI_DAY_COLOR;

  #include "/src/writebuffers.glsl"
}

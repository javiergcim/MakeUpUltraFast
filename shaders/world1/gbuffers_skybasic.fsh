#version 120
/* MakeUp - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
varying vec3 up_vec;  // Flat
varying vec4 star_data;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);
  vec3 background_color = HI_DAY_COLOR;

  #include "/src/writebuffers.glsl"
}

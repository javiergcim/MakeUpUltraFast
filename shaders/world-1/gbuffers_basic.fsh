#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
in vec4 tint_color;

void main() {
  vec4 block_color = tint_color;

  #include "/src/writebuffers.glsl"
}

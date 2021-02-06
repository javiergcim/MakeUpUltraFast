#version 130
/* MakeUp Ultra Fast - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;

// 'Global' constants from system
uniform sampler2D colortex0;

void main() {
  vec4 block_color = texture(colortex0, texcoord) * tint_color;

  #include "/src/writebuffers.glsl"
}

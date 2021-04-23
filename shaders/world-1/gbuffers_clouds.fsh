#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
in vec2 texcoord;
in vec4 tint_color;

// 'Global' constants from system
uniform sampler2D tex;

void main() {
  vec4 block_color = texture(tex, texcoord) * tint_color;

  #include "/src/writebuffers.glsl"
}

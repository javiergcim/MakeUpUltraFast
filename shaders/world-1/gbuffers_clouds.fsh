#version 120
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;

void main() {
  vec4 block_color = texture2D(tex, texcoord) * tint_color;

  #include "/src/writebuffers.glsl"
}

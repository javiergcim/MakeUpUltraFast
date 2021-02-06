#version 130
/* MakeUp Ultra Fast - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 current_fog_color;

// 'Global' constants from system
uniform sampler2D tex;
uniform float far;

void main() {
  vec4 block_color = texture(tex, texcoord) * tint_color;

  #include "/src/cloudfinalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

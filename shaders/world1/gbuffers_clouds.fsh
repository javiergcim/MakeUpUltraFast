#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform sampler2D tex;
uniform float far;

// Varyings (per thread shared variables)
in vec2 texcoord;
in vec4 tint_color;
in float frog_adjust;
flat in vec3 current_fog_color;


void main() {
  vec4 block_color = texture(tex, texcoord) * tint_color;

  #include "/src/cloudfinalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
in vec2 texcoord;
in vec4 tint_color;
in float frog_adjust;
flat in vec3 current_fog_color;

// 'Global' constants from system
uniform sampler2D tex;
uniform float far;

void main() {
  #if V_CLOUDS == 0
    vec4 block_color = texture(tex, texcoord) * tint_color;
    #include "/src/cloudfinalcolor.glsl"
  #else
    vec4 block_color = vec4(0.0);
  #endif
  #include "/src/writebuffers.glsl"
}

#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

// 'Global' constants from system
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float rainStrength;
uniform int isEyeInWater;

// Varyings (per thread shared variables)
in vec4 tint_color;
in float frog_adjust;
flat in vec3 current_fog_color;

void main() {
  vec4 block_color = tint_color;

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

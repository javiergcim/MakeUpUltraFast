#version 120
/* MakeUp - gbuffers_clouds.fsh
Render: Basic elements

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float rainStrength;
uniform int isEyeInWater;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D colortex7;

// Varyings (per thread shared variables)
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 current_fog_color;  // Flat

varying vec2 texcoord;

void main() {
  vec4 block_color = tint_color;

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

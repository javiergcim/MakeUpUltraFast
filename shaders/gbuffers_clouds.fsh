#version 120
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 current_fog_color;  // Flat

// 'Global' constants from system
uniform sampler2D tex;
uniform float far;

void main() {
  #if V_CLOUDS == 0
    vec4 block_color = texture2D(tex, texcoord) * tint_color;
    #include "/src/cloudfinalcolor.glsl"
  #else
    vec4 block_color = vec4(0.0);
  #endif
  #include "/src/writebuffers.glsl"
}

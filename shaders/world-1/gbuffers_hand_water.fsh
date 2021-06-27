#version 120
/* MakeUp - gbuffers_hand_water.fsh
Render: Translucent hand objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord);

  block_color *= tint_color * vec4(real_light, 1.0);

  #include "/src/writebuffers.glsl"
}

#version 130
/* MakeUp Ultra Fast - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec3 up_vec;
varying vec4 star_data;

// 'Global' constants from system
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);

  #include "/src/writebuffers.glsl"
}

#version 120
/* MakeUp - gbuffers_weather.fsh
Render: Weather

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS
#if MC_VERSION >= 11300
  #define CLOUDS_SHADER
#endif

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;

// 'Global' constants from system
uniform sampler2D tex;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord) * tint_color;
  block_color.a *= .3;

  block_color *= vec4(real_light, 1.0);

  #include "/src/writebuffers.glsl"
}

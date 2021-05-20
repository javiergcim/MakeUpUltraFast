#version 130
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
in vec2 texcoord;
in vec2 lmcoord;
in vec4 tint_color;
in vec3 real_light;

// 'Global' constants from system
uniform sampler2D tex;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture(tex, texcoord);
  block_color.a *= .3;

  block_color *= vec4(real_light, 1.0);

  #include "/src/writebuffers.glsl"
}

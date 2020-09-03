#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 candle_color;
varying vec3 pseudo_light;
varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;
varying float illumination_y;

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform int entityId;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  // Thunderbolt render
  if (entityId == 11000.0){
    block_color = vec4(1.0, 1.0, 1.0, .8);
  }

  block_color *= tint_color * vec4(real_light, 1.0);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

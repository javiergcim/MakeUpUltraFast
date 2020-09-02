#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float emissive;
varying float magma;
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

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  if (emissive > 0.5) {  // Es emisivo (clásico)
    block_color *= (tint_color * vec4((candle_color + (pseudo_light * illumination_y)) * 1.2, 1.0));

  } else if (magma > 0.5) {  // Es magma (modelo de emisión nueva)
    block_color *= (tint_color * vec4(vec3(lmcoord.x * 1.1), 1.0));

  } else {  // No es bloque emisivo
    block_color *= tint_color * vec4(real_light, 1.0);
  }

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

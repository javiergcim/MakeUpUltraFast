#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

const bool generateShadowMipmap = true;
const int shadowMapResolution = 1024;
const float shadowDistance = 15.0f;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;

varying vec3 spos;

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform int isEyeInWater;

uniform sampler2DShadow shadowtex0;

float getShadow(sampler2DShadow shadowtex, in vec3 shadowpos) {
	float shadow = shadow2D(shadowtex, shadowpos).x;

	return shadow;
}

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

	float shadow = getShadow(shadowtex0, spos);

  block_color *= tint_color * vec4(real_light, 1.0) * vec4(vec3(shadow), 1.0);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

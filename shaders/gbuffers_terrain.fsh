#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

const int shadowMapResolution = 512;
const float shadowDistance = 64.0f;
const float shadowIntervalSize = 10.0f;
const float shadowDistanceRenderMul = -1.0f;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadow0MinMagNearest = true;
const bool 	shadowHardwareFiltering0 = false;
const bool 	shadowHardwareFiltering1 = true;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
// varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;

varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;

#if SHADOW_CASTING == 1
	varying vec3 shadow_pos;
	varying float NdotL;
#endif

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform int isEyeInWater;

uniform float rainStrength;
uniform float nightVision;

#if SHADOW_CASTING == 1
	uniform sampler2DShadow shadowtex1;
#endif

#if SHADOW_CASTING == 1
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord) * tint_color;

	#if SHADOW_CASTING == 1
    vec3 shadow_c = get_shadow(shadow_pos, NdotL);
    // block_color.rgb *= shadow_c;
		// shadow_c = min((shadow_c * .25) + .75, direct_light_strenght);
  #endif

	vec3 real_light =
    candle_color +
    (direct_light_color * min(shadow_c, direct_light_strenght) * (1.0 - (rainStrength * .3))) +
    omni_light;

	block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

	// block_color *= tint_color;

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

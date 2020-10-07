#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

const int shadowMapResolution = 512;
const float shadowDistance = 16.0f;
const float shadowDistanceRenderMul = -1.0f;
const bool 	shadowHardwareFiltering0 = true;
const bool 	shadowHardwareFiltering1 = false;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;

#if SHADOW_CASTING == 1
	varying vec3 shadow_pos;
	// varying float NdotL;
#endif

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform int isEyeInWater;

#if SHADOW_CASTING == 1
	uniform sampler2DShadow shadowtex0;
#endif

#if SHADOW_CASTING == 1
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

	#if SHADOW_CASTING == 1
    vec3 shadow_c = get_shadow(shadow_pos);
    block_color.rgb *= shadow_c;
  #endif

  block_color *= tint_color * vec4(real_light, 1.0);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

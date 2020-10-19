#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;

varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;

#if SHADOW_CASTING == 1
  varying vec3 shadow_pos;
#endif

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform int isEyeInWater;

uniform float nightVision;
uniform float rainStrength;

#if SHADOW_CASTING == 1
  uniform sampler2D gaux2;
  uniform float frameTimeCounter;
  uniform sampler2DShadow shadowtex1;
  uniform float shadow_force;
#endif

#if SHADOW_CASTING == 1
  #include "/lib/dither.glsl"
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord) * tint_color;

  #if SHADOW_CASTING == 1
    float shadow_c = get_shadow(shadow_pos);

    vec3 real_light =
    candle_color +
    (direct_light_color * min(shadow_c, direct_light_strenght) *
    (1.0 - (rainStrength * .3))) +
    omni_light;
  #else
    vec3 real_light =
      candle_color +
      (direct_light_color * direct_light_strenght *
        (1.0 - (rainStrength * .3))) +
      omni_light;
  #endif

  block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

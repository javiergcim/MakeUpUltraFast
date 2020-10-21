#version 120
/* MakeUp Ultra Fast - gbuffers_entities.fsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

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
  varying float shadow_mask;
  varying vec3 shadow_pos;
#endif

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform int entityId;
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
  float shadow_c;

  // Thunderbolt render
  if (entityId == 11000.0){
    block_color = vec4(1.0, 1.0, 1.0, .8);
  }

  #if SHADOW_CASTING == 1
    if (rainStrength < .95 && lmcoord.y > 0.005) {
      shadow_c = get_shadow(shadow_pos);
      shadow_c = mix(shadow_c, 1.0, rainStrength);
    } else {
      shadow_c = 1.0;
    }

    if (shadow_mask < 0.0) {
      shadow_c = 0.0;
    }

  #else
    shadow_c = 1.0;
  #endif

  vec3 real_light =
    (omni_light * (direct_light_strenght * .25 + .75)) +
    (direct_light_color * direct_light_strenght * shadow_c) * (1.0 - rainStrength) +
    candle_color;

  block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

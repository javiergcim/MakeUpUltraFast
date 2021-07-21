#version 120
/* MakeUp - gbuffers_entities.fsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;
uniform int entityId;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float light_mix;
uniform vec4 entityColor;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D gaux4;

#ifdef SHADOW_CASTING
  uniform int frame_mod;
  uniform sampler2DShadow shadowtex1;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float frog_adjust;

varying vec3 direct_light_color;  // Flat
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;

#ifdef SHADOW_CASTING
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

#ifdef SHADOW_CASTING
  #include "/lib/dither.glsl"
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  #if BLACK_ENTITY_FIX == 1
    vec4 block_color = texture2D(tex, texcoord);
    if (block_color.a < 0.1) {   // Black entities bug workaround
      discard;
    }
    block_color *= tint_color;
  #else
    vec4 block_color = texture2D(tex, texcoord) * tint_color;
  #endif

  float shadow_c;

  // Thunderbolt render
  if (entityId == 11000.0){
    block_color = vec4(1.0, 1.0, 1.0, .8);
  }

  #ifdef SHADOW_CASTING
    shadow_c = get_shadow(shadow_pos);
    shadow_c = mix(shadow_c, 1.0, shadow_diffuse);

  #else
    shadow_c = abs((light_mix * 2.0) - 1.0);
  #endif

  vec3 real_light =
    omni_light +
    (direct_light_strenght * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
    candle_color;

  block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);
  block_color.rgb = mix(block_color.rgb, entityColor.rgb, entityColor.a * .75);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

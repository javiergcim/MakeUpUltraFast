#version 120
/* MakeUp - gbuffers_hand_water.fsh
Render: Translucent hand objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define CLOUDS_SHADER

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D colortex7;

#ifdef SHADOW_CASTING
  uniform sampler2D colortex5;
  uniform int frame_mod;
  uniform sampler2DShadow shadowtex1;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 current_fog_color;  // Flat
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
  vec4 block_color = texture2D(tex, texcoord) * tint_color;
  float shadow_c;

  #ifdef SHADOW_CASTING
    shadow_c = get_shadow(shadow_pos);
    shadow_c = mix(shadow_c, 1.0, shadow_diffuse);

  #else
    shadow_c = 1.0;
  #endif

  vec3 real_light =
    omni_light +
    (direct_light_strenght * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
    candle_color;

  block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

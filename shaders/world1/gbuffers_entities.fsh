#version 130
/* MakeUp - gbuffers_entities.fsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;
uniform int entityId;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform vec4 entityColor;

#ifdef SHADOW_CASTING
  uniform sampler2D colortex5;
  uniform float frameTimeCounter;
  uniform sampler2DShadow shadowtex1;
#endif

// Varyings (per thread shared variables)
in vec2 texcoord;
in vec2 lmcoord;
in vec4 tint_color;
flat in vec3 current_fog_color;
in float frog_adjust;

flat in vec3 direct_light_color;
in vec3 candle_color;
in float direct_light_strenght;
in vec3 omni_light;

#ifdef SHADOW_CASTING
  in vec3 shadow_pos;
  in float shadow_diffuse;
#endif

#ifdef SHADOW_CASTING
  #include "/lib/dither.glsl"
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  #if BLACK_ENTITY_FIX == 1
    vec4 block_color = texture(tex, texcoord);
    if (block_color.a < 0.1) {   // Blacl entities bug workaround
      discard;
    }
    block_color *= tint_color;
  #else
    vec4 block_color = texture(tex, texcoord) * tint_color;
  #endif

  float shadow_c;

  #ifdef SHADOW_CASTING
    if (lmcoord.y > 0.005) {
      shadow_c = get_shadow(shadow_pos);
      shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
    } else {
      shadow_c = 1.0;
    }

  #else
    shadow_c = 1.0;
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

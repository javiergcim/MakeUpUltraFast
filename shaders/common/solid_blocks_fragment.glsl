#include "/lib/config.glsl"

#if defined THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform sampler2D tex;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float light_mix;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D gaux4;

#if defined GBUFFER_ENTITIES
  uniform int entityId;
  uniform vec4 entityColor;
#endif

#ifdef NETHER
  uniform vec3 fogColor;
#endif

#if defined SHADOW_CASTING
  uniform int frame_mod;
  uniform sampler2DShadow shadowtex1;
  #if defined COLORED_SHADOW
    uniform sampler2DShadow shadowtex0;
    uniform sampler2D shadowcolor0;
  #endif
#endif

#ifdef MATERIAL_GLOSS
  // Optifine menu bug workaround. Don't remove
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
  uniform int worldTime;
  uniform vec3 moonPosition;
  uniform vec3 sunPosition;
  #if defined THE_END
    uniform mat4 gbufferModelView;
  #endif
#endif

varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;

#if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
  varying float emmisive_type;
#endif

#ifdef FOLIAGE_V
  varying float is_foliage;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
  varying vec3 flat_normal;
  varying vec3 sub_position3;
  varying vec2 lmcoord_alt;
  varying float gloss_factor;
  varying float gloss_power;
  varying float luma_factor;
  varying float luma_power;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/dither.glsl"
  #include "/lib/shadow_frag.glsl"
#endif

#include "/lib/luma.glsl"

#if defined MATERIAL_GLOSS && !defined NETHER
  #include "/lib/material_gloss_fragment.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  #if defined GBUFFER_ENTITIES
    #if BLACK_ENTITY_FIX == 1
      vec4 block_color = texture2D(tex, texcoord);
      if (block_color.a < 0.1 && entityId != 10101) {   // Black entities bug workaround
        discard;
      }
      block_color *= tint_color;
    #else
      vec4 block_color = texture2D(tex, texcoord) * tint_color;
    #endif
  #else
    vec4 block_color = texture2D(tex, texcoord) * tint_color;
  #endif

  float block_luma = luma(block_color.rgb);

  vec3 final_candle_color = candle_color;
  #if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
    // float candle_luma = 1.0;
    if (emmisive_type > 0.5) {
      // candle_luma = luma(block_color.rgb);
      // final_candle_color *= candle_luma * 1.5;
      final_candle_color *= block_luma * 1.5;
    }
  #endif
  
  #ifdef GBUFFER_WEATHER
    block_color.a *= .5;
  #endif

  #if defined GBUFFER_ENTITIES
    // Thunderbolt render
    if (entityId == 10101){
      block_color.a = 1.0;
    }
  #endif

  #if defined SHADOW_CASTING && !defined NETHER
    #if defined COLORED_SHADOW
      vec3 shadow_c = get_colored_shadow(shadow_pos);
      shadow_c = mix(shadow_c, vec3(1.0), shadow_diffuse);
    #else
      float shadow_c = get_shadow(shadow_pos);
      shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
    #endif
  #else
    float shadow_c = abs((light_mix * 2.0) - 1.0);
  #endif

  #if defined GBUFFER_BEACONBEAM
    block_color.rgb *= 1.5;
  #else
    #if defined MATERIAL_GLOSS && !defined NETHER
    float material_gloss_factor =
      material_gloss(
        reflect(normalize(sub_position3), flat_normal),
        lmcoord_alt,
        gloss_power,
        flat_normal
      ) * gloss_factor;

    block_luma *= luma_factor;
    block_luma = pow(block_luma, luma_power);

    float material = material_gloss_factor * block_luma;
    vec3 real_light =
      omni_light +
      (shadow_c * ((direct_light_color * direct_light_strenght) + (direct_light_color * material))) * (1.0 - (rainStrength * 0.75)) +
      final_candle_color;
  #else
    vec3 real_light =
      omni_light +
      (shadow_c * direct_light_color * direct_light_strenght) * (1.0 - (rainStrength * 0.75)) +
      final_candle_color;
  #endif

    block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);
  #endif

  #if defined GBUFFER_ENTITIES
    if (entityId == 10101) {
      // Thunderbolt render
      block_color = vec4(1.0, 1.0, 1.0, 0.5);
    } else {
      block_color.rgb = mix(block_color.rgb, entityColor.rgb, entityColor.a * .75);
    }
  #endif

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

#if defined THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform sampler2D gtexture;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float light_mix;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D gaux4;
uniform float alphaTestRef;

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
#endif

in vec2 texcoord;
in vec4 tint_color;
in float frog_adjust;
flat in vec3 direct_light_color;
in vec3 candle_color;
in float direct_light_strenght;
in vec3 omni_light;
in float var_fog_frag_coord;

#if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
  in float emmisive_type;
#endif

#ifdef FOLIAGE_V
  in float is_foliage;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  in vec3 shadow_pos;
  in float shadow_diffuse;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/dither.glsl"
  #include "/lib/shadow_frag.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  // Toma el color puro del bloque
  #if defined GBUFFER_ENTITIES
    #if BLACK_ENTITY_FIX == 1
      vec4 block_color = texture(gtexture, texcoord);
      if (block_color.a < 0.1) {   // Blacl entities bug workaround
        discard;
      }
      block_color *= tint_color;
    #else
      vec4 block_color = texture(gtexture, texcoord) * tint_color;
    #endif
  #else
    vec4 block_color = texture(gtexture, texcoord) * tint_color;
  #endif

  vec3 final_candle_color = candle_color;
  #if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
    float candle_luma = 1.0;
    if (emmisive_type > 0.5) {
      candle_luma = luma(block_color.rgb);
      final_candle_color *= candle_luma * 1.5;
    }
  #endif
  
  #ifdef GBUFFER_WEATHER
    block_color.a *= .3;
  #endif

  #if defined GBUFFER_ENTITIES
    // Thunderbolt render
    if (entityId == 10101.0){
      block_color.a = 0.5;
    }
  #endif

  if(block_color.a < alphaTestRef) discard;  // Full transparency

  float shadow_c;

  #if defined SHADOW_CASTING && !defined NETHER
    shadow_c = get_shadow(shadow_pos);
    shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
  #else
    shadow_c = abs((light_mix * 2.0) - 1.0);
  #endif

  vec3 real_light =
    omni_light +
    (direct_light_strenght * shadow_c * direct_light_color) * (1.0 - (rainStrength * 0.75)) +
    final_candle_color;

  block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

  #if defined GBUFFER_ENTITIES
    // Damage flash
    block_color.rgb = mix(block_color.rgb, entityColor.rgb, entityColor.a * .75);

    // Thunderbolt render
    if (entityId == 10101){
      block_color.rgb = vec4(1.0, 1.0, 1.0, 0.5);
    }
  #endif

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

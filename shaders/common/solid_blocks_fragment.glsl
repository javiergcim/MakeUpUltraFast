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

#ifdef NETHER
  uniform vec3 fogColor;
#endif

#if defined SHADOW_CASTING
  uniform int frame_mod;
  uniform sampler2DShadow shadowtex1;
#endif

varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;
varying float var_fog_frag_coord;

#ifdef FOLIAGE_V
  varying float is_foliage;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/dither.glsl"
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(tex, texcoord) * tint_color;
  
  #ifdef GBUFFER_WEATHER
    block_color.a *= .3;
  #endif

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
    candle_color;

  block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

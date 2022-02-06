#include "/lib/config.glsl"

#if defined THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float light_mix;
uniform float far;
uniform float rainStrength;
uniform ivec2 eyeBrightnessSmooth;
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

#if defined FOLIAGE_V || defined THE_END || defined NETHER
  uniform mat4 gbufferModelView;
#endif

#if defined FOLIAGE_V || (defined SHADOW_CASTING)
  uniform mat4 gbufferModelViewInverse;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
#endif

#if WAVING == 1
  uniform vec3 cameraPosition;
  uniform float frameTimeCounter;
#endif

in ivec2 vaUV2;  // Light coordinates
in vec2 vaUV0;  // Texture coordinates
in vec4 vaColor;
in vec3 vaPosition;
in vec3 vaNormal;

out vec2 texcoord;
out vec4 tint_color;
out float frog_adjust;
flat out vec3 direct_light_color;
out vec3 candle_color;
out float direct_light_strenght;
out vec3 omni_light;
out float var_fog_frag_coord;

#if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
  out float emmisive_type;
#endif

#ifdef FOLIAGE_V
  out float is_foliage;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  out vec3 shadow_pos;
  out float shadow_diffuse;
#endif

#if defined FOLIAGE_V || defined GBUFFER_TERRAIN || defined GBUFFER_HAND
  attribute vec4 mc_Entity;
#endif

#if WAVING == 1
  attribute vec2 mc_midTexCoord;
#endif

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/shadow_vertex.glsl"
#endif

#if WAVING == 1
  #include "/lib/vector_utils.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  #include "/src/light_vertex.glsl"
  #include "/src/fog_vertex.glsl"

  #if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
    emmisive_type = 0.0;
    if (mc_Entity.x == ENTITY_EMMISIVE || mc_Entity.x == ENTITY_S_EMMISIVE) {
      emmisive_type = 1.0;
    }
  #endif

  #if defined SHADOW_CASTING && !defined NETHER
    #include "/src/shadow_src_vertex.glsl"
  #endif

  #ifdef FOLIAGE_V
    #ifdef SHADOW_CASTING
      if (is_foliage > .2) {
        direct_light_strenght = mix(direct_light_strenght, original_direct_light_strenght, pow(shadow_diffuse, .25));
      }
    #endif
  #endif
}

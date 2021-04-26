#version 130
/* MakeUp - gbuffers_terrain.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define FOLIAGE_V
#define EMMISIVE_V

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float light_mix;
uniform float far;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;

#ifdef SHADOW_CASTING
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
#endif

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform float rainStrength;

#if WAVING == 1
  uniform vec3 cameraPosition;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
out vec2 texcoord;
out vec2 lmcoord;
out vec4 tint_color;
flat out vec3 current_fog_color;
out float frog_adjust;

flat out vec3 direct_light_color;
out vec3 candle_color;
out float direct_light_strenght;
out vec3 omni_light;
flat out float is_foliage;

#ifdef SHADOW_CASTING
  out vec3 shadow_pos;
  out float shadow_diffuse;
#endif

attribute vec4 mc_Entity;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if WAVING == 1
  attribute vec2 mc_midTexCoord;
  #include "/lib/vector_utils.glsl"
#endif

#ifdef SHADOW_CASTING
  #include "/lib/shadow_vertex.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"

  // Special entities
  float emissive;
  float magma;
  if (mc_Entity.x == ENTITY_EMISSIVE) { // Emissive entities
    emissive = 1.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_MAGMA) {
    emissive = 0.0;
    magma = 1.0;
  } else {
    emissive = 0.0;
    magma = 0.0;
  }

  #include "/src/light_vertex.glsl"
  #include "/src/fog_vertex.glsl"

  #ifdef SHADOW_CASTING
    #include "/src/shadow_src_vertex.glsl"
  #endif
}

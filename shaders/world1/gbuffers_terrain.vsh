#version 130
/* MakeUp Ultra Fast - gbuffers_terrain.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define FOLIAGE_V
#define EMMISIVE_V

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

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
uniform mat4 gbufferModelView;

#if SHADOW_CASTING == 1
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
#endif

uniform mat4 gbufferModelViewInverse;

#if WAVING == 1
  uniform vec3 cameraPosition;
  uniform float frameTimeCounter;
  uniform float rainStrength;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 current_fog_color;
varying float frog_adjust;

varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;
varying float is_foliage;

#if SHADOW_CASTING == 1
  varying float shadow_mask;
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

attribute vec4 mc_Entity;

#if AA_TYPE == 1
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if WAVING == 1
  attribute vec2 mc_midTexCoord;
  #include "/lib/vector_utils.glsl"
#endif

#if SHADOW_CASTING == 1
  #include "/lib/shadow_vertex.glsl"
#endif

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

  #if SHADOW_CASTING == 1
    #include "/src/shadow_src_vertex.glsl"
  #endif
}

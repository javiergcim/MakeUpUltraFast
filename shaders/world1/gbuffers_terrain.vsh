#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define FOLIAGE_V
#define EMMISIVE_V
#define THE_END

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

uniform sampler2D texture;
uniform float nightVision;
uniform float rainStrength;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;

#if WAVING == 1
  uniform vec3 cameraPosition;
  uniform mat4 gbufferModelView;
  uniform mat4 gbufferModelViewInverse;
  uniform float frameTimeCounter;
  uniform float wetness;
  uniform sampler2D noisetex;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;

attribute vec4 mc_Entity;

#include "/lib/basic_utils.glsl"

#if WAVING == 1
  attribute vec2 mc_midTexCoord;
  #include "/lib/vector_utils.glsl"
#endif

void main() {
  #include "/src/basiccoords_vector.glsl"
  #include "/src/position_vector.glsl"

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

  #include "/src/light_vector.glsl"
}

#version 130
/* MakeUp - gbuffers_hand.vsh
Render: Hand opaque objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

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
uniform float nightVision;
uniform float rainStrength;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;

#ifdef SHADOW_CASTING
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
  uniform mat4 gbufferModelViewInverse;
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

#ifdef SHADOW_CASTING
  out vec3 shadow_pos;
  out float shadow_diffuse;
#endif

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#ifdef SHADOW_CASTING
  #include "/lib/shadow_vertex.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  #include "/src/light_vertex.glsl"
  #include "/src/fog_vertex.glsl"

  #ifdef SHADOW_CASTING
    #include "/src/shadow_src_vertex.glsl"
  #endif
}

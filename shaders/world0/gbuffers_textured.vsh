#version 130
/* MakeUp Ultra Fast - gbuffers_textured.vsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define ENTITY_GLINT

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

#if SHADOW_CASTING == 1
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
  uniform mat4 gbufferModelViewInverse;
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

#if SHADOW_CASTING == 1
  varying float shadow_mask;
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

#if AA_TYPE == 1
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if SHADOW_CASTING == 1
  #include "/lib/shadow_vertex.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  #include "/src/light_vertex.glsl"
  #include "/src/fog_vertex.glsl"

  #if SHADOW_CASTING == 1
    #include "/src/shadow_src_vertex.glsl"
  #endif
}

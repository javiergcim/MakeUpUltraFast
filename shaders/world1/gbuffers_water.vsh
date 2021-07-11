#version 120
/* MakeUp - gbuffers_water.vsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define WATER_F
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
uniform float nightVision;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

#ifdef SHADOW_CASTING
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 water_normal;  // Flat
varying float block_type;  // Flat
varying vec4 worldposition;
varying vec4 position2;
varying vec3 tangent;
varying vec3 binormal;

varying vec3 direct_light_color;  // Flat
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;
varying float visible_sky;

#ifdef SHADOW_CASTING
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#ifdef SHADOW_CASTING
  #include "/lib/shadow_vertex.glsl"
#endif

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/light_vertex.glsl"

  water_normal = normal;
  vec4 position1 = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
  position2 = gl_ModelViewMatrix * gl_Vertex;
  worldposition = position1 + vec4(cameraPosition.xyz, 0.0);
  gl_Position = gl_ProjectionMatrix * gbufferModelView * position1;

  #if AA_TYPE > 0
    gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
  #endif

  tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
  binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));
  gl_FogFragCoord = length(gl_Position.xyz);

  // Special entities
  block_type = 0.0;  // 3 - Water, 2 - Glass, ? - Other
  if (mc_Entity.x == ENTITY_WATER) {  // Water
    block_type = 3.0;
  } else if (mc_Entity.x == ENTITY_STAINED) {  // Glass
    block_type = 2.0;
  }

  #include "/src/fog_vertex.glsl"

  #ifdef SHADOW_CASTING
    vec3 position = position1.xyz;
    #include "/src/shadow_src_vertex.glsl"
  #endif
}

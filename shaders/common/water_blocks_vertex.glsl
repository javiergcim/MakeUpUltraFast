#include "/lib/config.glsl"

#ifdef THE_END
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
uniform float nightVision;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float rainStrength;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

#if defined SHADOW_CASTING && !defined NETHER
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
#endif

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 water_normal;
varying float block_type;
varying vec4 worldposition;
varying vec4 position2;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;
varying float visible_sky;
varying vec3 up_vec;

#if defined SHADOW_CASTING && !defined NETHER
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/shadow_vertex.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/light_vertex.glsl"

  water_normal = normal;
  vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
  position2 = gl_ModelViewMatrix * gl_Vertex;
  worldposition = position + vec4(cameraPosition.xyz, 0.0);
  gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

  #if AA_TYPE == 1
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif

  tangent = normalize(normalMatrix * at_tangent.xyz);
  binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));
  var_fog_frag_coord = length(gl_Position.xyz);

  // Special entities
  block_type = 0.0;  // 3 - Water, 2 - Glass, ? - Other
  if (mc_Entity.x == ENTITY_WATER) {  // Water
    block_type = 3.0;
  } else if (mc_Entity.x == ENTITY_STAINED) {  // Glass
    block_type = 2.0;
  }

  up_vec = normalize(gbufferModelView[1].xyz);

  #include "/src/fog_vertex.glsl"

  #if defined SHADOW_CASTING && !defined NETHER
    #include "/src/shadow_src_vertex.glsl"
  #endif
}

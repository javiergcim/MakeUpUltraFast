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
uniform float light_mix;
uniform float far;
uniform float nightVision;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;

#ifdef DYN_HAND_LIGHT
  uniform int heldItemId;
  uniform int heldItemId2;
#endif

#ifdef UNKNOWN_DIM
  uniform sampler2D lightmap;
#endif

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
varying vec3 fragposition;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying float visible_sky;
varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#if defined SHADOW_CASTING && !defined NETHER
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  varying float umbral;
  varying vec3 cloud_color;
  varying vec3 dark_cloud_color;
#endif

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

#if AA_TYPE > 1
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/shadow_vertex.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
  
  #include "/src/basiccoords_vertex.glsl"

  vec4 position2 = gl_ModelViewMatrix * gl_Vertex;
  fragposition = position2.xyz;
  vec4 position = gbufferModelViewInverse * position2;
  worldposition = position + vec4(cameraPosition.xyz, 0.0);
  gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

  #if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif

  vec3 viewPos = gl_Position.xyz / gl_Position.w;
  vec4 homopos = gbufferProjectionInverse * vec4(viewPos, 1.0);
  viewPos = homopos.xyz / homopos.w;
  gl_FogFragCoord = length(viewPos.xyz);

  // Reflected sky color calculation
  #include "/src/sky_color_vertex.glsl"

  #include "/src/light_vertex.glsl"
  water_normal = normal;

  tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
  binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));

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

  #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    #include "/lib/volumetric_clouds_vertex.glsl"
  #endif
}

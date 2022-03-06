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
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

#if defined SHADOW_CASTING && !defined NETHER
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
#endif

in ivec2 vaUV2;  // Light coordinates
in vec2 vaUV0;  // Texture coordinates
in vec4 vaColor;
in vec3 vaPosition;
in vec3 vaNormal;

out vec2 texcoord;
out vec2 lmcoord;
out vec4 tint_color;
out float frog_adjust;
flat out vec3 water_normal;
flat out float block_type;
out vec4 worldposition;
out vec4 position2;
out vec3 tangent;
out vec3 binormal;
flat out vec3 direct_light_color;
out vec3 candle_color;
out float direct_light_strenght;
out vec3 omni_light;
out float visible_sky;
flat out vec3 up_vec;
out float var_fog_frag_coord;

#if defined SHADOW_CASTING && !defined NETHER
  out vec3 shadow_pos;
  out float shadow_diffuse;
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
  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
  vec2 va_UV2 = vec2(vaUV2);
  
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/light_vertex.glsl"

  water_normal = normal;
  vec4 full_position = vec4(vaPosition + chunkOffset, 1.0);
  vec4 position = gbufferModelViewInverse * modelViewMatrix * full_position;
  position2 = modelViewMatrix * full_position;
  worldposition = position + vec4(cameraPosition.xyz, 0.0);
  gl_Position = projectionMatrix * gbufferModelView * position;

  #if AA_TYPE == 1
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif

  tangent = normalize(normalMatrix * at_tangent.xyz);
  binormal = normalize(normalMatrix * -cross(vaNormal, at_tangent.xyz));
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

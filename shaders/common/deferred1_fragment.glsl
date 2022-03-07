/* Exits */
out vec4 outColor0;
out vec4 outColor1;

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

// #ifdef THE_END
//   #include "/lib/color_utils_end.glsl"
// #elif defined NETHER
//   #include "/lib/color_utils_nether.glsl"
// #else
//   #include "/lib/color_utils.glsl"
// #endif

uniform sampler2D colortex0;
// uniform ivec2 eyeBrightnessSmooth;
// uniform int isEyeInWater;
// uniform sampler2D depthtex0;
// uniform float far;
// uniform float near;
// uniform float blindness;
// uniform float rainStrength;
// uniform int current_hour_floor;
// uniform int current_hour_ceil;
// uniform float current_hour_fract;
uniform sampler2D gaux3;

// #ifdef NETHER
//   uniform vec3 fogColor;
// #endif

// #if AO == 1
//   uniform float inv_aspect_ratio;
//   uniform float fov_y_inv;
// #endif

// #if V_CLOUDS != 0
//   uniform sampler2D noisetex;
//   uniform vec3 cameraPosition;
//   uniform vec3 sunPosition;
// #endif

// uniform mat4 gbufferModelViewInverse;
// uniform mat4 gbufferProjectionInverse;
// uniform float pixel_size_x;
// uniform float pixel_size_y;

// #if AO == 1 || V_CLOUDS != 0
//   uniform mat4 gbufferProjection;
//   uniform int frame_mod;
//   uniform float frameTimeCounter;
// #endif

in vec2 texcoord;
// flat in vec3 up_vec;  // Flat

// #include "/lib/depth.glsl"
// #include "/lib/luma.glsl"

// #if AO == 1 || V_CLOUDS != 0
//   #include "/lib/dither.glsl"
// #endif

// #if AO == 1
//   #include "/lib/ao.glsl"
// #endif

// #if V_CLOUDS != 0
//   #include "/lib/projection_utils.glsl"

//   #ifdef THE_END
//     #include "/lib/volumetric_clouds_end.glsl"
//   #else
//     #include "/lib/volumetric_clouds.glsl"
//   #endif
  
// #endif

void main() {
  vec4 block_color = texture(colortex0, texcoord);
  vec4 effects_color = texture(gaux3, texcoord);

  /* DRAWBUFFERS:14 */
  outColor0 = vec4(mix(block_color.rgb, effects_color.rgb, effects_color.a), block_color.a);
  outColor1 = vec4(mix(block_color.rgb, effects_color.rgb, effects_color.a), 1.0);

  // outColor0 = vec4(mix(block_color.rgb, effects_color.rgb, 1.0), block_color.a);
  // outColor1 = vec4(mix(block_color.rgb, effects_color.rgb, 1.0), 1.0);

  // outColor0 = vec4(vec3(effects_color.a), 1.0);
  // outColor1 = vec4(vec3(effects_color.a), 1.0);

}

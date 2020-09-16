#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Tonemap

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#if AA_TYPE == 2
  uniform sampler2D colortex3;  // TAA past averages
  uniform sampler2D depthtex0;
  uniform float pixelSizeX;
  uniform float pixelSizeY;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform vec3 cameraPosition;
  uniform vec3 previousCameraPosition;
  uniform mat4 gbufferPreviousProjection;
  uniform mat4 gbufferPreviousModelView;
  uniform float viewWidth;
  uniform float viewHeight;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"

#if AA_TYPE == 2
  #include "/lib/luma.glsl"
  #include "/lib/fast_taa.glsl"
#endif

void main() {
  // x: Block, y: Sky ---
  float candle_bright = (eyeBrightnessSmooth.x / 240.0) * .1;
  float exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );
  float exposure =
    ((eyeBrightnessSmooth.y / 240.0) * exposure_coef) + candle_bright;

  // Map from 1.0 - 0.0 to 1.0 - 3.0
  exposure = (exposure * -2.0) + 3.0;

  vec4 block_color = texture2D(colortex0, texcoord);

  #if AA_TYPE == 2
    block_color.rgb = fast_taa(block_color.rgb);
    gl_FragData[3] = block_color;
  #endif

  block_color.rgb *= exposure;
  block_color.rgb = tonemap(block_color.rgb);

  // gl_FragData[1] = vec4(0.0);  // ¿Performance?
  gl_FragData[2] = block_color;
}

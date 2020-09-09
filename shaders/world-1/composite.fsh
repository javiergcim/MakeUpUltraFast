#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Tonemap and void

Javier Garduño - GNU Lesser General Public License v3.0
*/

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float far;
uniform float near;
uniform sampler2D depthtex0;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils_nether.glsl"
#include "/lib/tone_maps.glsl"
#include "/lib/depth.glsl"
#include "/lib/basic_utils.glsl"

void main() {
  float d = texture2D(depthtex0, texcoord.xy).r;

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

  vec4 block_color;

  block_color = mix(
    texture2D(colortex0, texcoord),
    vec4(gl_Fog.color.rgb * .5, 1.0),
    sqrt(ld(d))
  );

  block_color.rgb *= exposure;
  block_color.rgb = tonemap(block_color.rgb);

  gl_FragData[2] = block_color;
  gl_FragData[1] = vec4(0.0);  // ¿Performance?
}

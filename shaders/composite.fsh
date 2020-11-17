#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;

#if AO == 1
  uniform sampler2D colortex5;
  uniform float inv_aspect_ratio;
  uniform mat4 gbufferProjection;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils.glsl"
#include "/lib/depth.glsl"

#if AO == 1
  #include "/lib/dither.glsl"
  #include "/lib/ao.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex0, texcoord);
  float d = texture2D(depthtex0, texcoord).r;
  #if AO == 1
    // AO distance attenuation
    float ao_att = sqrt(ld(d));
    float final_ao = mix(dbao(), 1.0, ao_att);
    // float final_ao = mix(dbao_old(), 1.0, ao_att);
    block_color *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
    // block_color = vec4(vec3(ld(d)), 1.0);
  #endif

  // Niebla
  if (isEyeInWater == 1) {
    block_color.rgb = mix(
      block_color.rgb,
      skyColor * .5 * ((eyeBrightnessSmooth.y * .8 + 48) / 240.0),
      sqrt(ld(d))
      );
  } else if (isEyeInWater == 2) {
    block_color = mix(
      block_color,
      vec4(1.0, .1, 0.0, 1.0),
      sqrt(ld(d))
      );
  }
  /* DRAWBUFFERS:012 */
  gl_FragData[1] = vec4(block_color.rgb, d);
}

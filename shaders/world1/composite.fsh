#version 130
/* MakeUp Ultra Fast - composite1.fsh
Render: DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform float rainStrength;

#if DOF == 1
  uniform float centerDepthSmooth;
  uniform float inv_aspect_ratio;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform float viewWidth;
  uniform float viewHeight;
  uniform float frameTimeCounter;
  uniform sampler2D colortex5;
  uniform float fov_y_inv;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

#if DOF == 1
  #include "/lib/dither.glsl"
  #include "/lib/blur.glsl"
#endif

void main() {
  vec3 block_color = texture(colortex0, texcoord).rgb;
  float d = texture(depthtex0, texcoord).r;
  float linear_d = ld(d);

  #if DOF == 1
    block_color = noised_blur(
      vec4(block_color, d),
      colortex0,
      texcoord,
      DOF_STRENGTH
      );

  #endif

  if (blindness > .01) {
    block_color =
    mix(block_color, vec3(0.0), blindness * linear_d * far * .12);
  }

  /* DRAWBUFFERS:012 */
  gl_FragData[1] = vec4(block_color, d);
}

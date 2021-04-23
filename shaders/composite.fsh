#version 130
/* MakeUp - composite.fsh
Render: DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform int isEyeInWater;
uniform float rainStrength;

#ifdef DOF
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

#ifdef DOF
  const bool colortex1MipmapEnabled = true;
#endif

// Varyings (per thread shared variables)
in vec2 texcoord;

#ifdef BLOOM
  flat in float exposure;
#endif

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

#ifdef DOF
  #include "/lib/dither.glsl"
  #include "/lib/blur.glsl"
#endif

void main() {
  vec4 block_color = texture(colortex1, texcoord);
  float d = block_color.a;
  float linear_d = ld(d);

  #ifdef DOF
    block_color.rgb = noised_blur(
      block_color,
      colortex1,
      texcoord,
      DOF_STRENGTH
      );

  #endif

  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  #ifdef BLOOM
    // Bloom source
    float bloom_luma =
      smoothstep(0.85, 0.97, luma(block_color.rgb * exposure)) * 0.4;

    /* DRAWBUFFERS:12 */
    gl_FragData[0] = block_color;
    gl_FragData[1] = block_color * bloom_luma;
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

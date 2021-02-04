#version 130
/* MakeUp Ultra Fast - composite1.fsh
Render: DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

uniform sampler2D colortex1;

#if DOF == 1
  uniform float centerDepthSmooth;
  uniform float inv_aspect_ratio;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform float viewWidth;
  uniform float viewHeight;
  uniform float frameTimeCounter;
  uniform sampler2D colortex5;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  #include "/lib/dither.glsl"
  #include "/lib/blur.glsl"
#endif

void main() {

  #if DOF == 1
    vec4 color_depth = texture(colortex1, texcoord);
    vec3 block_color = noised_blur(
      color_depth,
      colortex1,
      texcoord,
      DOF_STRENGTH
      );

    /* DRAWBUFFERS:1 */
    gl_FragData[0] = vec4(block_color, color_depth.a);
  #else
    vec4 block_color = texture(colortex1, texcoord);

    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

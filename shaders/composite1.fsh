#version 120
/* MakeUp - final.fsh
Render: Bloom and volumetric light

Javier Garduño - GNU Lesser General Public License v3.0
*/

// #define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex5;
uniform sampler2D colortex2;
uniform float frameTimeCounter;
uniform float inv_aspect_ratio;

#ifdef DOF
  uniform float centerDepthSmooth;
  // uniform float inv_aspect_ratio;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform float viewWidth;
  uniform float viewHeight;
  // uniform float frameTimeCounter;
  uniform float fov_y_inv;
  //uniform sampler2D colortex5;
#endif

#ifdef DOF
  const bool colortex1MipmapEnabled = true;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/bloom.glsl"

#ifdef DOF
  #include "/lib/dither.glsl"
  #include "/lib/blur.glsl"
#endif

#ifdef BLOOM
  const bool colortex2MipmapEnabled = true;
#endif

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);

  #if defined BLOOM || defined DOF
    #if MC_VERSION >= 11300
      #if AA_TYPE > 0
        float dither = shifted_texture_noise_64(gl_FragCoord.xy, colortex5);
      #else
        float dither = texture_noise_64(gl_FragCoord.xy, colortex5);
      #endif
    #else
      #if AA_TYPE > 0
        float dither = timed_hash12(gl_FragCoord.xy);
      #else
        float dither = dither_grad_noise(gl_FragCoord.xy);
      #endif
    #endif
  #endif

  #ifdef DOF
    block_color.rgb = noised_blur(
      block_color,
      colortex1,
      texcoord,
      DOF_STRENGTH,
      dither
      );
  #endif

  #ifdef BLOOM
    vec3 bloom = mipmap_bloom(colortex2, texcoord, dither);
    block_color.rgb += bloom;
  #endif

  #ifdef MOTION_BLUR
    #ifdef DOF
      /* DRAWBUFFERS:01 */
      gl_FragData[0] = block_color;
      gl_FragData[1] = block_color;
    #else
      /* DRAWBUFFERS:1 */
      gl_FragData[0] = block_color;
    #endif
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

#version 120
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex1;
uniform sampler2D colortex5;
uniform sampler2D colortex2;
uniform int frame_mod;
uniform float inv_aspect_ratio;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/dither.glsl"
#include "/lib/bloom.glsl"

#ifdef BLOOM
  const bool colortex2MipmapEnabled = true;
#endif

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);

  #if defined BLOOM || defined DOF
    #if AA_TYPE > 0
      float dither = shifted_dither_grad_noise(gl_FragCoord.xy);
    #else
      float dither = dither_grad_noise(gl_FragCoord.xy);
    #endif
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

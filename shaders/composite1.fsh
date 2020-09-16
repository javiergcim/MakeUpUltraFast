#version 120
/* MakeUp Ultra Fast - final.fsh
Render: FXAA and blur precalculation

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

#if AA_TYPE == 2
  // const bool colortex3Clear = false;
  uniform sampler2D colortex3;  // TAA past averages
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/luma.glsl"
#include "/lib/fxaa_intel.glsl"

void main() {
  vec4 block_color = texture2D(colortex2, texcoord);

  #if AA_TYPE == 1
    vec3 color = fxaa311(block_color.rgb, AA);
    #if DOF == 1
      gl_FragData[4] = vec4(color, 1.0);  // gaux1
    #else
      gl_FragData[0] = vec4(color, 1.0);  // colortex0
    #endif
    // gl_FragData[1] = vec4(0.0);  // ¿Performance?

  #else
    #if DOF == 1
      gl_FragData[4] = block_color;  // gaux1
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif
  // gl_FragData[1] = vec4(0.0);  // ¿Performance?

  #endif

  #if AA_TYPE == 2
    gl_FragData[3] = texture2D(colortex3, texcoord);
  #endif
}

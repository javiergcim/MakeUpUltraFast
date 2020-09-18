#version 120
/* MakeUp Ultra Fast - final.fsh
Render: Antialiasing

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

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
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if AA_TYPE == 1
  #include "/lib/luma.glsl"
  #include "/lib/fxaa_intel.glsl"
#elif AA_TYPE == 2
  #include "/lib/luma.glsl"
  #include "/lib/fast_taa.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex2, texcoord);

  #if AA_TYPE == 1
    block_color.rgb = fxaa311(block_color.rgb, AA);
    #if DOF == 1
      gl_FragData[4] = block_color;  // colortex4
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif
    // gl_FragData[1] = vec4(0.0);  // ¿Performance?

  #elif AA_TYPE == 2
    block_color.rgb = fast_taa(block_color.rgb);
    gl_FragData[3] = block_color;  // To TAA averages
    // gl_FragData[3] = vec4(1.0, 0.0, 0.0, 1.0);
    #if DOF == 1
      gl_FragData[4] = block_color;  // colortex4
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif
  #else
    #if DOF == 1
      gl_FragData[4] = block_color;  // colortex4
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif
  // gl_FragData[1] = vec4(0.0);  // ¿Performance?

  #endif
}

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

#if DOF == 1
  uniform sampler2D depthtex1;
  uniform float centerDepthSmooth;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/luma.glsl"
#include "/lib/fxaa_intel.glsl"

#if DOF == 1
  #include "/lib/blur.glsl"
#endif

void main() {
  #if DOF == 1
    float the_depth = texture2D(depthtex1, texcoord).r;
    float blur_radius = 0.0;
    if (the_depth > 0.56) {
      blur_radius =
        max(abs(the_depth - centerDepthSmooth) - 0.0001, 0.0);
      blur_radius = blur_radius / sqrt(0.1 + blur_radius * blur_radius) * DOF_STRENGTH;
      // blur_radius /= (sqrt(0.1 + blur_radius * blur_radius) * DOF_STRENGTH);
    }
  #endif

  #if AA_TYPE == 1 0
    vec3 color = fxaa311(texture2D(colortex2, texcoord).rgb, AA);
    #if DOF == 1
      gl_FragData[4] = vec4(color, blur_radius);  // gaux1
    #else
      gl_FragData[0] = vec4(color, 1.0);  // colortex0
    #endif

    gl_FragData[1] = vec4(0.0);  // ¿Performance?

  #else
    #if DOF == 1
      gl_FragData[4] = vec4(texture2D(colortex2, texcoord).rgb, blur_radius);  // gaux1
    #else
      gl_FragData[0] = texture2D(colortex2, texcoord);  // colortex0
    #endif
  gl_FragData[1] = vec4(0.0);  // ¿Performance?
  #endif
}

#version 120
/* MakeUp Ultra Fast - final.fsh
Render: FXAA and blur precalculation

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define AA 4 // [0 4 6 12] Set antialiasing quality
#define DOF 1  // [0 1] Enables depth of field
#define DOF_STRENGTH 2  // [2 3 4 5 6 7 8 9 10 11 12 13 14]  Depth of field streght

// 'Global' constants from system
uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

#if DOF == 1
  uniform sampler2D depthtex0;
  uniform mat4 gbufferProjectionInverse;
  uniform float centerDepthSmooth;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  varying float dof_dist;
#endif

#include "/lib/luma.glsl"
#include "/lib/fxaa_intel.glsl"

#if DOF == 1
  #include "/lib/blur.glsl"
#endif

void main() {
  #if DOF == 1
    vec3 pos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
    vec4 vec = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
  	pos = vec.xyz / vec.w;
    float dist = length(pos);
    float blur_radius = min(abs(dist - dof_dist) / dof_dist, 1.0);
    // blur_radius *= blur_radius * DOF_STRENGTH * 0.00390625; // blur_radius /= 256.0;
    blur_radius *= blur_radius * DOF_STRENGTH * 0.00390625;
  #endif

  #if AA != 0
    vec3 color = fxaa311(texture2D(colortex0, texcoord).rgb, AA);
    gl_FragData[0] = vec4(color, 1.0);
  #else
    gl_FragData[0] = texture2D(colortex0, texcoord);
  #endif

  #if DOF == 1
    gl_FragData[4] = vec4(blur_radius);  //gaux1
  #else
    gl_FragData[1] = vec4(0.0);  // ¿Performance?
  #endif
}

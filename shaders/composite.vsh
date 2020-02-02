#version 120
/* MakeUp Ultra Fast - composite.vsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define DOF 1  // [0 1] Enables depth of field

#include "/lib/globals.glsl"

// 'Global' constants from system
#if DOF == 1
  uniform mat4 gbufferProjectionInverse;
  uniform float centerDepthSmooth;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;  // Current thread coordinate
varying float iswater;

#if DOF == 1
  varying float dof_dist;
#endif

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;

  #if DOF == 1
    vec4 vec = gbufferProjectionInverse * vec4(0.0, 0.0, centerDepthSmooth * 2.0 - 1.0, 1.0);
  	dof_dist = -vec.z / vec.w;
  #endif
}

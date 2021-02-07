#version 130
/* MakeUp Ultra Fast - composite1.fsh
Render: DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END

#include "/lib/config.glsl"

#if DOF == 1
  uniform mat4 gbufferProjection;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  varying float fov_y_inv;
#endif

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;

  #if DOF == 1
    fov_y_inv = 1.0 / atan(1.0 / gbufferProjection[1].y);
  #endif
}

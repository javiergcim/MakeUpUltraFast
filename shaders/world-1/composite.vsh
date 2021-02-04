#version 130
/* MakeUp Ultra Fast - composite.vsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

#if AO == 1
  uniform mat4 gbufferProjection;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if AO == 1
  varying float fov_y_inv;
#endif

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;

  #if AO == 1
    fov_y_inv = 1.0 / atan(1.0 / gbufferProjection[1].y) * 0.5;
  #endif
}

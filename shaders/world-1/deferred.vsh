#version 130
/* MakeUp - deferred.vsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// 'Global' constants from system
#if AO == 1
  uniform mat4 gbufferProjection;
#endif

// Varyings (per thread shared variables)
out vec2 texcoord;

#if AO == 1
  out float fov_y_inv;
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  #if AO == 1
    fov_y_inv = 1.0 / atan(1.0 / gbufferProjection[1].y) * 0.5;
  #endif
}

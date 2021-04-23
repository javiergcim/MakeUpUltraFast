#version 130
/* MakeUp - deferred.fsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END

#include "/lib/config.glsl"

// 'Global' constants from system
#if AO == 1
  uniform mat4 gbufferProjection;
#endif

// Varyings (per thread shared variables)
out vec2 texcoord;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;
}

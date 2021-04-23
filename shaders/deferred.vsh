#version 130
/* MakeUp - deferred.vsh
Render: Ambient occlusion, volumetric clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

uniform mat4 gbufferModelView;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec3 up_vec;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  // gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
  up_vec = normalize(gbufferModelView[1].xyz);
}

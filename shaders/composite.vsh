#version 120
/* MakeUp Ultra Fast - composite.vsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// 'Global' constants from system
uniform vec3 sunPosition;
uniform vec3 moonPosition;

// Varyings (per thread shared variables)
varying vec4 texcoord;  // Current thread coordinate
varying float iswater;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0;
}

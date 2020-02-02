#version 120
/* MakeUp Ultra Fast - composite.vsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;  // Current thread coordinate
varying float iswater;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
}

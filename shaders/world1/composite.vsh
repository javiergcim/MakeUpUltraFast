#version 120
/* MakeUp Ultra Fast - composite.vsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Varyings (per thread shared variables)
varying vec2 texcoord;  // Current thread coordinate

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
}

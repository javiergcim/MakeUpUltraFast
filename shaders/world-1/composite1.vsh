#version 140
/* MakeUp Ultra Fast - composite1.vsh
Render: DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Varyings (per thread shared variables)
varying vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
}

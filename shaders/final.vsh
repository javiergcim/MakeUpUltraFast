#version 120
/* MakeUp Ultra Fast - final.vsh
Render: (last renderer)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;  // Current thread coordinate

void main() {
  /* función principal del vector shader final.

  */

  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
}

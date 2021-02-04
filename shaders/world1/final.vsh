#version 130
/* MakeUp Ultra Fast - final.fsh
Render: Final renderer

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END

// Varyings (per thread shared variables)
varying vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
}

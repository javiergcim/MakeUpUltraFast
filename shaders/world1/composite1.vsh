#version 400 compatibility
/* MakeUp Ultra Fast - composite1.fsh
Render: Antialiasing and motion blur

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END

// Varyings (per thread shared variables)
varying vec2 texcoord;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;
}

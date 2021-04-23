#version 130
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Varyings (per thread shared variables)
out vec2 texcoord;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;
}

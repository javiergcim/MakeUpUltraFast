#version 120
/* MakeUp Ultra Fast - gbuffers_spidereyes.vsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Varyings (per thread shared variables)
varying vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;

  gl_FogFragCoord = length(gl_Position.xyz);
}

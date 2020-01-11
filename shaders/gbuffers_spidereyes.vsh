#version 120
/* MakeUp Ultra Fast - gbuffers_spidereyes.vsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// Varyings (per thread shared variables)
varying vec4 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0;

  gl_FogFragCoord = length(gl_Position.xyz);
}

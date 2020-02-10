#version 120
/* MakeUp Ultra Fast - gbuffers_clouds.vsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 color;

void main() {
  gl_Position = ftransform();
  gl_FogFragCoord = length(gl_Position.xyz);

  texcoord = gl_MultiTexCoord0.xy;

  color = gl_Color;
}

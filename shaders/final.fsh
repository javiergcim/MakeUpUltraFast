#version 120
/* MakeUp Ultra Fast - final.fsh
Render: (last renderer)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// Buffer formats
const int R11F_G11F_B10F = 0;
const int RGB10_A2 = 1;
const int RGBA16 = 2;
const int RGB16 = 3;
const int RGB8 = 4;
const int R8 = 5;

const int colortex0Format = R11F_G11F_B10F; // G_COLOR
const int colortex1Format = RGB8;
const int colortex2Format = RGB8;
const int colortex3Format = RGB8;
const int gaux1Format = RGB8;
const int gaux2Format = RGB8;
const int gaux3Format = RGB8;
const int gaux4Format = RGB8;

// 'Global' constants from system
uniform sampler2D G_COLOR;

// Varyings (per thread shared variables)
varying vec4 texcoord;

void main() {
  /* función principal del fragment shader final.

  */

	vec3 color = texture2D(G_COLOR, texcoord.xy).rgb;
  gl_FragColor = vec4(color, 1.0);
}

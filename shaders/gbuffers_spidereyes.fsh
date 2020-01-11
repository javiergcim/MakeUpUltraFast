#version 120
/* MakeUp Ultra Fast - gbuffers_spidereyes.fsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define REFLECTION 1 // [0 1] 0 = Off, 1 = On
#define REFRACTION 1 // [0 1] 0 = Off, 1 = On

#include "/lib/globals.glsl"

// Varyings (per thread shared variables)
varying vec4 texcoord;

// 'Global' constants from system
uniform sampler2D texture;
uniform int fogMode;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord.xy);

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;
	// gl_FragData[1] = vec4(0.0);  // Not needed. Performance trick
}

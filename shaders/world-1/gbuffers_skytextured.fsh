#version 120
/* MakeUp Ultra Fast - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NICE_WATER 1  // [0 1] Turn on for reflection and refraction capabilities.

varying vec2 texcoord;
varying vec4 tint_color;
uniform sampler2D texture;

void main() {
  vec4 block_color = texture2D(texture, texcoord) * tint_color;
  gl_FragData[0] = block_color;
  #if NICE_WATER == 1
    gl_FragData[5] = block_color;
  #else
    gl_FragData[1] = vec4(0.0);
  #endif
}

#version 140

#include "/lib/config.glsl"

uniform sampler2D gcolor;

varying vec2 texcoord;

void main() {

  vec4 block_color = texture(gcolor, texcoord);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = block_color;
}

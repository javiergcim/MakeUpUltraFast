#version 120

#define THE_END

#include "/lib/config.glsl"

uniform sampler2D tex;

varying vec2 texcoord;

void main() {
  vec4 block_color = texture2D(tex, texcoord);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = block_color;
}

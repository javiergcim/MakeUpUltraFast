#version 140

#define THE_END

#include "/lib/config.glsl"

uniform sampler2D gcolor;

varying vec2 texcoord;

void main() {

  vec4 block_color = texture(gcolor, texcoord);

  gl_FragData[0] = block_color;
}

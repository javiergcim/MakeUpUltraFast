#version 130

#define THE_END

#include "/lib/config.glsl"

uniform sampler2D texture;

varying vec2 texcoord;

void main() {

  vec4 block_color = texture2D(texture, texcoord);

  gl_FragData[0] = block_color;
}

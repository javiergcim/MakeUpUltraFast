#version 400 compatibility

#define THE_END

#include "/lib/config.glsl"

uniform sampler2D tex;

varying vec2 texcoord;

void main() {

  vec4 block_color = texture(tex, texcoord);

  gl_FragData[0] = block_color;
}

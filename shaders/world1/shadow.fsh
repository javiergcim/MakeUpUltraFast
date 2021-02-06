#version 130

#define THE_END

#include "/lib/config.glsl"

uniform sampler2D colortex0;

varying vec2 texcoord;

void main() {

  vec4 block_color = texture(colortex0, texcoord);

  gl_FragData[0] = block_color;
}

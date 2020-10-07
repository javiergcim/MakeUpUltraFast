#version 120

uniform sampler2D tex;

varying vec2 coord;
varying vec4 tint_color;

uniform int blockEntityId;

void main() {
  vec4 block_color = texture2D(tex, coord, -1) * vec4(tint_color.rgb, 1.0);

  if (blockEntityId == 138) discard;

  gl_FragData[0] = block_color;
}

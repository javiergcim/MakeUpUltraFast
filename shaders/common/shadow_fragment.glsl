/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

uniform sampler2D tex;
uniform float alphaTestRef;

in vec2 texcoord;

void main() {

  vec4 block_color = texture2D(tex, texcoord);

  if(block_color.a < alphaTestRef) discard;

  /* DRAWBUFFERS:0 */
  outColor0 = block_color;
}

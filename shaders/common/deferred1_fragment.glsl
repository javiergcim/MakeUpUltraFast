/* Exits */
out vec4 outColor0;
out vec4 outColor1;

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

uniform sampler2D colortex0;
uniform sampler2D gaux3;

in vec2 texcoord;

void main() {
  vec4 block_color = texture(colortex0, texcoord);
  vec4 effects_color = texture(gaux3, texcoord);

  /* DRAWBUFFERS:14 */
  outColor0 = vec4(mix(block_color.rgb, effects_color.rgb, effects_color.a), block_color.a);
  outColor1 = vec4(mix(block_color.rgb, effects_color.rgb, effects_color.a), 1.0);
}
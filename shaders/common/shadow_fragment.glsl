/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef;

in vec2 texcoord;

#ifdef COLORED_SHADOW
  in float is_water;
#endif

void main() {
  #ifdef COLORED_SHADOW
    if (is_water > 0.98) discard;  // Is water
  #endif

  vec4 block_color = texture(gtexture, texcoord);

  if (block_color.a < alphaTestRef) discard;

  /* DRAWBUFFERS:0 */
  outColor0 = block_color;
}

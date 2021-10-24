/* MakeUp - aberration.glsl
Color aberration effect.
*/

vec3 color_aberration() {
  vec2 offset = texcoord - 0.5;

  offset *= vec2(0.125) * CHROMA_ABER_STRENGHT;

  vec3 aberrated_color = vec3(0.0);

  aberrated_color.r = texture(colortex0, texcoord - offset).r;
  aberrated_color.g = texture(colortex0, texcoord - (offset * 0.5)).g;
  aberrated_color.b = texture(colortex0, texcoord).b;

  return aberrated_color;
}

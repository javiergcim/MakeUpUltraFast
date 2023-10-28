/* MakeUp - aberration.glsl
Color aberration effect.
*/

vec3 color_aberration() {
  vec2 offset = texcoord - 0.5;

  offset *= vec2(0.125) * CHROMA_ABER_STRENGTH;

  vec3 aberrated_color = vec3(0.0);

  aberrated_color.r = texture2D(colortex1, texcoord - offset).r;
  aberrated_color.g = texture2D(colortex1, texcoord - (offset * 0.5)).g;
  aberrated_color.b = texture2D(colortex1, texcoord).b;

  return aberrated_color;
}

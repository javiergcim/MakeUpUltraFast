/* MakeUp - aberration.glsl
Color aberration effect.
*/

vec3 color_aberration() {
    vec2 offset = texcoord - 0.5;

    offset *= vec2(0.125) * CHROMA_ABER_STRENGTH;

    vec3 aberrated_color = vec3(0.0);

    aberrated_color.r = texture2DLod(colortex1, texcoord - offset, 0.0).r;
    aberrated_color.g = texture2DLod(colortex1, texcoord - (offset * 0.5), 0.0).g;
    aberrated_color.b = texture2DLod(colortex1, texcoord, 0.0).b;

    return aberrated_color;
}

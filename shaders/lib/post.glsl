vec3 sharpen(sampler2D image, vec3 color, vec2 coords) {
    vec3 sum = -texture2DLod(image, coords + vec2(-pixelSizeX, 0.0), 0.0).rgb;
    sum -= texture2DLod(image, coords + vec2(0.0, -pixelSizeY), 0.0).rgb;
    sum += 11.0 * color;
    sum -= texture2DLod(image, coords + vec2(0.0, pixelSizeY), 0.0).rgb;
    sum -= texture2DLod(image, coords + vec2(pixelSizeX, 0.0), 0.0).rgb;

    return sum * 0.14285714285714285;
}

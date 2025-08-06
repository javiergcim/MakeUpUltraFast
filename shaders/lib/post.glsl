vec3 sharpen(sampler2D image, vec3 color, vec2 coords) {
    vec3 sum = -texture2DLod(image, coords + vec2(-pixel_size_x, 0.0), 0.0).rgb;
    sum -= texture2DLod(image, coords + vec2(0.0, -pixel_size_y), 0.0).rgb;
    sum += 11.0 * color;
    sum -= texture2DLod(image, coords + vec2(0.0, pixel_size_y), 0.0).rgb;
    sum -= texture2DLod(image, coords + vec2(pixel_size_x, 0.0), 0.0).rgb;

    return sum * 0.14285714285714285;
}

vec3 edge_detect(sampler2D image, vec3 color, vec2 coords) {
    vec3 sum = -texture2DLod(image, coords + vec2(-pixel_size_x, -pixel_size_y), 0.0).rgb;
    sum -= texture2DLod(image, coords + vec2(pixel_size_x, -pixel_size_y), 0.0).rgb;
    sum += 4.0 * color;
    sum -= texture2DLod(image, coords + vec2(-pixel_size_x, pixel_size_y), 0.0).rgb;
    sum -= texture2DLod(image, coords + vec2(pixel_size_x, pixel_size_y), 0.0).rgb;

    return vec3(length(sum)) * 0.5773502691896258;
}

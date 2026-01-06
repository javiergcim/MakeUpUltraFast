#if MC_VERSION >= 11300
    uniform vec2 taaOffset;
#else
    uniform int frameMod;
    uniform float pixel_size_x;
    uniform float pixel_size_y;

    vec2[16] offset_array = vec2[16] (
        vec2(0.5, 0.5),
        vec2(-0.5, -0.5),
        vec2(-0.5, 0.5),
        vec2(0.5, -0.5),
        vec2(0.5, 0.5),
        vec2(-0.5, -0.5),
        vec2(-0.5, 0.5),
        vec2(0.5, -0.5),
        vec2(0.5, 0.5),
        vec2(-0.5, -0.5),
        vec2(-0.5, 0.5),
        vec2(0.5, -0.5),
        vec2(0.5, 0.5),
        vec2(-0.5, -0.5),
        vec2(-0.5, 0.5),
        vec2(0.5, -0.5)
    );

    vec2 taaOffset = offset_array[frameMod] * vec2(pixel_size_x, pixel_size_y);
#endif

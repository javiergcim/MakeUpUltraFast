#if MC_VERSION >= 11300
    uniform vec2 taaOffset;
#else
    uniform int frameMod;
    uniform float pixelSizeX;
    uniform float pixelSizeY;

    vec2[16] offsetArray = vec2[16] (
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

    vec2 taaOffset = offsetArray[frameMod] * vec2(pixelSizeX, pixelSizeY);
#endif

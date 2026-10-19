#if MC_VERSION >= 11604
    uniform vec2 taaOffset;
    uniform vec2 fixedTaaCorrection;
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
    vec2 fixedTaaCorrection = vec2(0.51, 0.51) * vec2(pixelSizeX, pixelSizeY);
#endif

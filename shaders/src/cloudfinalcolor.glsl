
#if MC_VERSION < 12106
    blockColor.rgb =
        mix(
            blockColor.rgb,
            texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb,
            clamp(pow(gl_FogFragCoord / (far * 1.66), 1.5), 0.0, 1.0)
        );
#else
    blockColor.rgb =
        mix(
            blockColor.rgb,
            texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb,
            clamp(pow(gl_FogFragCoord / (2000.0), 1.5), 0.0, 1.0)
        );
#endif


#if MC_VERSION < 12106
    block_color.rgb =
        mix(
            block_color.rgb,
            texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb,
            clamp(pow(gl_FogFragCoord / (far * 1.66), 1.5), 0.0, 1.0)
        );
#else
    block_color.rgb =
        mix(
            block_color.rgb,
            texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb,
            clamp(pow(gl_FogFragCoord / (2000.0), 1.5), 0.0, 1.0)
        );
#endif

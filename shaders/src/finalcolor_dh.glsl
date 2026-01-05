#if defined DH_WATER
    if(isEyeInWater == 0) {
        vec3 fog_texture = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb;
        blockColor.rgb = mix(blockColor.rgb, fog_texture, frog_adjust);
    }
#elif defined NETHER
    #if NETHER_FOG_DISTANCE == 1
        blockColor.rgb = mix(fogColor * 0.1, vec3(1.0), 0.04);
    #else
        blockColor.rgb = mix(blockColor.rgb, mix(fogColor * 0.1, vec3(1.0), 0.04), frog_adjust);
    #endif
#else
    vec3 fog_texture = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb;
    blockColor.rgb = mix(blockColor.rgb, fog_texture, frog_adjust);
#endif
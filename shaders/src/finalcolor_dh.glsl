#if defined DH_WATER
    if(isEyeInWater == 0) {
        vec3 fog_texture = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY), 0.0).rgb;
        blockColor.rgb = mix(blockColor.rgb, fog_texture, frogAdjust);
    }
#elif defined NETHER
    #if NETHER_FOG_DISTANCE == 1
        blockColor.rgb = mix(fogColor * 0.1, vec3(1.0), 0.04);
    #else
        blockColor.rgb = mix(blockColor.rgb, mix(fogColor * 0.1, vec3(1.0), 0.04), frogAdjust);
    #endif
#else
    vec3 fog_texture = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY), 0.0).rgb;
    blockColor.rgb = mix(blockColor.rgb, fog_texture, frogAdjust);
#endif
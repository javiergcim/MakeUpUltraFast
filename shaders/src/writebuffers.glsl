#if defined GBUFFER_ENTITIES || defined GBUFFER_ENTITIES_GLOW || defined GBUFFER_BLOCK || defined GBUFFER_BLOCK_TRANSLUCENT || defined GBUFFER_TEXTURED || defined GBUFFER_HAND || defined GBUFFER_HAND_WATER || defined GBUFFER_ARMOR_GLINT || defined GBUFFER_SPIDEREYES || defined GBUFFER_WEATHER || defined GBUFFER_PARTICLES || defined GBUFFER_PARTICLES_TRANSLUCENT
    #if defined GBUFFER_ENTITIES && MC_VERSION >= 260000
        /* DRAWBUFFERS:142 */
        blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));
        gl_FragData[0] = blockColor;
        gl_FragData[1] = blockColor;
        gl_FragData[2] = vec4(1.0);
    #else
        /* DRAWBUFFERS:12 */
        blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));
        gl_FragData[0] = blockColor;
        gl_FragData[1] = vec4(1.0);
    #endif
#elif defined GBUFFER_WATER
    /* DRAWBUFFERS:12 */
    gl_FragData[0] = blockColor;
    gl_FragData[1] = vec4(0.0);
#elif (defined SPECIAL_TRANS && MC_VERSION >= 11300)
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = blockColor;
#elif defined SET_FOG_COLOR
    /* DRAWBUFFERS:17 */
    blockColor = clamp(blockColor, vec3(0.0), vec3(50.0));
    gl_FragData[0] = vec4(blockColor,1.0);
    gl_FragData[1] = vec4(blockColor,1.0);
    // colortex2 is the selective-TAA entity mask. Prepare is a full-screen pass,
    // so clear it here before entity/hand programs mark their pixels.
    // gl_FragData[2] = vec4(0.0);
#elif MC_VERSION < 11604 && defined GBUFFER_SKYBASIC
    /* DRAWBUFFERS:17 */
    blockColor = clamp(blockColor,vec4(0.0),vec4(vec3(50.0),1.0));
    gl_FragData[0]=blockColor; gl_FragData[1]=blockColor;
#else
    /* DRAWBUFFERS:1 */
    blockColor=clamp(blockColor,vec4(0.0),vec4(vec3(50.0),1.0));
    gl_FragData[0]=blockColor;
#endif

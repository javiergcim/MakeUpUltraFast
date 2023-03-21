#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#elif (defined SPECIAL_TRANS && MC_VERSION >= 11300) || defined GBUFFER_HAND_WATER
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#else
  #if defined SET_FOG_COLOR
    /* DRAWBUFFERS:17 */
    gl_FragData[0] = vec4(block_color, 1.0);
    gl_FragData[1] = vec4(block_color, 1.0);
  #elif MC_VERSION < 11604 && defined GBUFFER_SKYBASIC
    /* DRAWBUFFERS:17 */
    gl_FragData[0] = block_color;
    gl_FragData[1] = block_color;
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
#endif

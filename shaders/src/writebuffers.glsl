#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#elif (defined SPECIAL_TRANS && MC_VERSION >= 11300) || defined GBUFFER_HAND_WATER
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#else
  #ifdef SET_FOG_COLOR
    /* DRAWBUFFERS:07 */
    gl_FragData[0] = vec4(block_color, 1.0);
    #if defined THE_END || defined NETHER
      gl_FragData[1] = vec4(block_color, 1.0);
    #else
      gl_FragData[1] = vec4(block_color, 1.0);
    #endif
  #else
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;
  #endif
#endif

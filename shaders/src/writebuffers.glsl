#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#elif defined CLOUDS_SHADER
  #if MC_VERSION >= 11300
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #else
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = block_color;
  #endif
#else
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = block_color;
#endif

#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  outColor0 = block_color;
#elif defined CLOUDS_SHADER
  /* DRAWBUFFERS:1 */
  outColor0 = block_color;
#else
  #ifdef SET_FOG_COLOR
    /* DRAWBUFFERS:0 */
    outColor0 = block_color;
  #else
    /* DRAWBUFFERS:0 */
    outColor0 = block_color;
  #endif
#endif

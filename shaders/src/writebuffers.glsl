#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  outColor0 = block_color;
#elif defined CLOUDS_SHADER
  /* DRAWBUFFERS:1 */
  outColor0 = block_color;
#else
  #ifdef SET_FOG_COLOR
    /* DRAWBUFFERS:07 */
    outColor0 = block_color;
    #if defined THE_END || defined NETHER
      outColor1 = vec4(background_color, 1.0);
    #else
      outColor1 = vec4(background_color, 0.0);
    #endif
  #else
    /* DRAWBUFFERS:0 */
    outColor0 = block_color;
  #endif
#endif

#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#elif defined CLOUDS_SHADER
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#else
  #ifdef SET_FOG_COLOR
    /* DRAWBUFFERS:07 */
    gl_FragData[0] = block_color;
    #if defined THE_END || defined NETHER
      gl_FragData[1] = vec4(background_color, 1.0);
    #else
      gl_FragData[1] = vec4(background_color, 0.0);
    #endif
  #else
    /* DRAWBUFFERS:0 */
    gl_FragData[1] = block_color;
  #endif
#endif

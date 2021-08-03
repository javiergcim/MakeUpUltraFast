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
  #ifdef SET_FOG_COLOR
    /* DRAWBUFFERS:07 */
    gl_FragData[0] = block_color;
    #ifdef THE_END
      gl_FragData[1] = vec4(background_color, 1.0);
    #else
      gl_FragData[1] = vec4(background_color, 0.0);
    #endif
  #else
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;
  #endif
#endif

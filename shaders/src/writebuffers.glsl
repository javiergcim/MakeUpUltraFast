#ifdef WATER_F

  /* DRAWBUFFERS:0 */

  gl_FragData[0] = block_color;

#else

  /* DRAWBUFFERS:01234 */

  gl_FragData[0] = block_color;
  gl_FragData[4] = block_color;

#endif

#ifdef WATER_F

  /* DRAWBUFFERS:1 */

  gl_FragData[0] = block_color;

#else

  /* DRAWBUFFERS:04 */

  gl_FragData[0] = block_color;
  gl_FragData[1] = block_color;

#endif

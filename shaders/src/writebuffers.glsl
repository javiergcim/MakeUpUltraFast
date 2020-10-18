#ifdef WATER_F

  /* DRAWBUFFERS:0 */

  gl_FragData[0] = block_color;

#else

  /* DRAWBUFFERS:012345 */

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;

#endif

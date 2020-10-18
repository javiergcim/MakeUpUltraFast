#ifdef WATER_F

  /**/

  gl_FragData[0] = block_color;

#else

  /**/

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;

#endif

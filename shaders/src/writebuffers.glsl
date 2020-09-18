#ifdef WATER_F

  gl_FragData[0] = block_color;
  gl_FragData[1] = vec4(0.0);

#else

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;

#endif

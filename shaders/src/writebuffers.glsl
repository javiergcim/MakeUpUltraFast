#ifdef WATER_F

  gl_FragData[0] = block_color;
  gl_FragData[1] = vec4(0.0);  // ¿Performance?

#else

  gl_FragData[0] = block_color;
  #if NICE_WATER == 1
    gl_FragData[5] = block_color;
  #else
    gl_FragData[1] = vec4(0.0);
  #endif
  
#endif

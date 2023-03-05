#ifdef WATER_F
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#elif (defined PARTICLE_SHADER && MC_VERSION >= 11300)
  /* DRAWBUFFERS:01 */
  gl_FragData[0] = block_color;
  gl_FragData[1] = block_color;
#elif defined GBUFFER_HAND_WATER
  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
#else
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = block_color;
#endif

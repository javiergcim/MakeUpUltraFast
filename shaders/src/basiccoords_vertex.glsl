#ifdef ENTITY_GLINT
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
#else
   texcoord = gl_MultiTexCoord0.xy;
#endif

lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

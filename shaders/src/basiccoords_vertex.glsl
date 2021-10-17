#ifdef ENTITY_GLINT
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
#else
  texcoord = gl_MultiTexCoord0.xy;
#endif

#ifndef SHADER_BASIC
  #ifdef WATER_F
    // lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * 0.0041841004184100415;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  #else
    // vec2 lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * 0.0041841004184100415;
    vec2 lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  #endif
#endif

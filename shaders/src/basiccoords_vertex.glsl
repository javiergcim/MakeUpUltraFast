texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

#ifndef SHADER_BASIC
  #ifdef WATER_F
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * 1.0323886639676114;
  #else
    vec2 lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * 1.0323886639676114;
  #endif
#endif

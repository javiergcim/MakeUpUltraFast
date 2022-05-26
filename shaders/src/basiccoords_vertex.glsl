#ifdef ENTITY_GLINT
  texcoord = (textureMatrix * vec4(vaUV0, 0.0, 1.0)).xy;
#else
  texcoord = vaUV0;
#endif

#ifndef SHADER_BASIC
  #ifdef WATER_F
    lmcoord = va_UV2 * 0.0041841004184100415;
  #else
    vec2 lmcoord = va_UV2 * 0.0041841004184100415;
  #endif
#endif

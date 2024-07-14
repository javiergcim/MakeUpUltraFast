position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
gl_Position = dhProjection * gbufferModelView * position;

#if AA_TYPE > 1
  gl_Position.xy += taa_offset * gl_Position.w;
#endif

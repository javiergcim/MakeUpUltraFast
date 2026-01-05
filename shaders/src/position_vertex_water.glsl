vec4 viewSpacePos4D = gl_ModelViewMatrix * gl_Vertex;
fragposition = viewSpacePos4D.xyz;
vec4 position = gbufferModelViewInverse * viewSpacePos4D;
worldposition = position + vec4(cameraPosition.xyz, 0.0);
gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
gl_FogFragCoord = length(viewSpacePos4D.xyz);


#if AA_TYPE > 1
    gl_Position.xy += taaOffset * gl_Position.w;
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    vWorldPos = position.xyz;
#endif

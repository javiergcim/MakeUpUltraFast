vec4 position2 = gl_ModelViewMatrix * gl_Vertex;
fragposition = position2.xyz;
vec4 position = gbufferModelViewInverse * position2;
worldposition = position + vec4(cameraPosition.xyz, 0.0);
gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
gl_FogFragCoord = length(position2.xyz);


#if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
#endif




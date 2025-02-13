vec4 position2 = gl_ModelViewMatrix * gl_Vertex;
fragposition = position2.xyz;
vec4 position = gbufferModelViewInverse * position2;
worldposition = position + vec4(cameraPosition.xyz, 0.0);
gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

#if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
#endif

vec4 homopos = gbufferProjectionInverse * vec4(gl_Position.xyz / gl_Position.w, 1.0);
vec3 viewPos = homopos.xyz / homopos.w;
gl_FogFragCoord = length(viewPos);




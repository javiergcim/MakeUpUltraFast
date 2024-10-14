#include "/lib/config.glsl"

/* Uniforms */

uniform mat4 gbufferProjectionInverse;

/* Ins / Outs */

varying vec2 texcoord;
varying float var_fog_frag_coord;

/* Utility functions */

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    vec4 homopos = gbufferProjectionInverse * vec4(gl_Position.xyz / gl_Position.w, 1.0);
    vec3 viewPos = homopos.xyz / homopos.w;
    gl_FogFragCoord = length(viewPos.xyz);
}
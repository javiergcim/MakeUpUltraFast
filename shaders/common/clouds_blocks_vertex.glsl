#include "/lib/config.glsl"

/* Uniforms */

uniform mat4 gbufferProjectionInverse;

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    uniform float rainStrength;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 gbufferModelViewInverse;
#endif

/* Ins / Outs */

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    varying vec2 texcoord;
    varying vec4 tint_color;
#endif

/* Utility functions */

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    #include "/lib/luma.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    #if V_CLOUDS == 0 || defined UNKNOWN_DIM
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        tint_color = gl_Color;
    #endif
    #include "/src/position_vertex.glsl"
}

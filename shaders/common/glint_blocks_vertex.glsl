#include "/lib/config.glsl"

/* Uniforms */

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"

    tint_color = gl_Color;
}

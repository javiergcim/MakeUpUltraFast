#include "/lib/config.glsl"

/* Uniforms */

uniform float viewHeight;
uniform float viewWidth;

/* Ins / Outs */

varying vec4 tint_color;

/* Utility functions */

#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/mu_ftransform.glsl"

// MAIN FUNCTION ------------------

void main() {
    tint_color = gl_Color;
    gl_Position = mu_ftransform();

    #if AA_TYPE > 1
        gl_Position.xy += taa_offset * gl_Position.w;
    #endif
}

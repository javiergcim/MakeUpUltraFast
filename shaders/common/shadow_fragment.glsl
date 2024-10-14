#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;

/* Ins / Outs */

varying vec2 texcoord;

#ifdef COLORED_SHADOW
    varying float is_water;
#endif

// MAIN FUNCTION ------------------

void main() {
    #ifdef COLORED_SHADOW
        if(is_water > 0.98)
            discard;  // Is water
    #endif

    vec4 block_color = texture2D(tex, texcoord);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;
}

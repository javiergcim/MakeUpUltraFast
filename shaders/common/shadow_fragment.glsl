#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;

/* Ins / Outs */

varying vec2 texcoord;
varying float is_noshadow;

#ifdef COLORED_SHADOW
    varying float is_water;
#endif

// MAIN FUNCTION ------------------

void main() {
    #ifdef COLORED_SHADOW
        if(is_water > 0.98)  // Water do not project shadows
            discard;
    #endif

    if (is_noshadow > 0.98) {  // Objects without shadow projection
        discard;
    }

    vec4 block_color = texture2D(tex, texcoord);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;
}

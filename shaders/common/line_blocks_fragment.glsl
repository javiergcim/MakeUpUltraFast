/* Utility functions */

#include "/lib/config.glsl"

/* Ins / Outs */

varying vec4 tint_color;

void main() {
    vec4 block_color = tint_color;

    #include "/src/writebuffers.glsl"
}

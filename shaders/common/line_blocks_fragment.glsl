/* Utility functions */

#include "/lib/config.glsl"

/* Ins / Outs */

varying vec4 tintColor;

void main() {
    vec4 blockColor = tintColor;

    #include "/src/writebuffers.glsl"
}

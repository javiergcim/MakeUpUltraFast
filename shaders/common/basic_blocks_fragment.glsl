#include "/lib/config.glsl"

/* Uniforms, ins, outs */
varying vec4 tintColor;
varying vec2 texcoord;
varying vec3 basicLight;

// MAIN FUNCTION ------------------

void main() {
    vec4 blockColor = tintColor;
    blockColor.rgb *= basicLight;

    #include "/src/writebuffers.glsl"
}

#include "/lib/config.glsl"

/* Uniforms, ins, outs */
varying vec4 tint_color;
varying vec2 texcoord;
varying vec3 basic_light;

// MAIN FUNCTION ------------------

void main() {
    vec4 blockColor = tint_color;
    blockColor.rgb *= basic_light;

    #include "/src/writebuffers.glsl"
}

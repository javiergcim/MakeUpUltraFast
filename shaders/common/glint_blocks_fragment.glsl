#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;

// MAIN FUNCTION ------------------

void main() {
    // Toma el color puro del bloque
    vec4 block_color = texture2D(tex, texcoord) * tint_color * 0.5;

    #include "/src/writebuffers.glsl"
}
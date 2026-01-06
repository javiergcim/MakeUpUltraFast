#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tintColor;
varying float exposure;

// MAIN FUNCTION ------------------

void main() {
    // Toma el color puro del bloque
    vec4 blockColor = texture2D(tex, texcoord) * tintColor / max(0.001, exposure);

    #include "/src/writebuffers.glsl"
}
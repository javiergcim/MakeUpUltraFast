#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;
uniform float far;
uniform float blindness;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
    uniform float darknessLightFactor;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    uniform float pixel_size_x;
    uniform float pixel_size_y;
    uniform sampler2D gaux4;
#endif

/* Ins / Outs */

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    varying vec2 texcoord;
    varying vec4 tint_color;
#endif

// Main function ---------

void main() {
    #if V_CLOUDS == 0 || defined UNKNOWN_DIM
        vec4 block_color = texture2D(tex, texcoord) * tint_color;
        #include "/src/cloudfinalcolor.glsl"
        #include "/src/writebuffers.glsl"
    #elif MC_VERSION <= 11300
        vec4 block_color = vec4(0.0);
        #include "/src/writebuffers.glsl"
    #endif
}

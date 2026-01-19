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
    uniform float pixelSizeX;
    uniform float pixelSizeY;
    uniform sampler2D gaux4;
#endif

/* Ins / Outs */

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    varying vec2 texcoord;
    varying vec4 tintColor;
#endif

// Main function ---------

void main() {
    #if V_CLOUDS == 0 || defined UNKNOWN_DIM
        vec4 blockColor = texture2D(tex, texcoord) * tintColor;
        #include "/src/cloudfinalcolor.glsl"
        #include "/src/writebuffers.glsl"
    #elif MC_VERSION <= 11300
        vec4 blockColor = vec4(0.0);
        #include "/src/writebuffers.glsl"
    #endif
}

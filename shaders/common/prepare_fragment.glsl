#include "/lib/config.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform mat4 gbufferProjectionInverse;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;

/* Ins / Outs */

varying vec3 up_vec;
varying vec3 ZenithSkyColor;
varying vec3 horizonSkyColor;

/* Utility functions */

#include "/lib/dither.glsl"

// MAIN FUNCTION ------------------

void main() {
    #if defined THE_END || defined NETHER
        vec3 blockColor = ZENITH_DAY_COLOR;
    #else

        #if AA_TYPE > 0
            float dither = shiftedRDither(gl_FragCoord.xy);
        #else
            float dither = dither13(gl_FragCoord.xy);
        #endif

        dither = (dither - .5) * 0.0625;

        vec4 fragpos =
            gbufferProjectionInverse *
            (vec4(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
        vec3 nfragpos = normalize(fragpos.xyz);
        float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
        vec3 blockColor =
            mix(horizonSkyColor, ZenithSkyColor, smoothstep(0.0, 1.0, pow(n_u, 0.333)));

        blockColor = xyz_to_rgb(blockColor);
    #endif
    
    #include "/src/writebuffers.glsl"
}
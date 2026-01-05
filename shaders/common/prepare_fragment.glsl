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
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float rainStrength;

/* Ins / Outs */

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

/* Utility functions */

#include "/lib/dither.glsl"

// MAIN FUNCTION ------------------

void main() {
    #if defined THE_END || defined NETHER
        vec3 blockColor = ZENITH_DAY_COLOR;
    #else

        #if AA_TYPE > 0
            float dither = shifted_r_dither(gl_FragCoord.xy);
        #else
            float dither = dither13(gl_FragCoord.xy);
        #endif

        dither = (dither - .5) * 0.0625;

        vec4 fragpos =
            gbufferProjectionInverse *
            (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
        vec3 nfragpos = normalize(fragpos.xyz);
        float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
        vec3 blockColor =
            mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, pow(n_u, 0.333)));

        blockColor = xyz_to_rgb(blockColor);
    #endif
    
    #include "/src/writebuffers.glsl"
}
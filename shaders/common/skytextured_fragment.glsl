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

uniform sampler2D tex;

#ifdef NETHER
    uniform vec3 fogColor;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;  // Flat

// MAIN FUNCTION ------------------

void main() {
    #if defined THE_END
        vec4 block_color = vec4(ZENITH_DAY_COLOR, 0.0);
        // vec3 background_color = ZENITH_DAY_COLOR;
    #elif defined NETHER  // Unused
        vec4 background_color_full = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
        vec3 background_color = background_color_full.rgb;
        vec4 block_color = vec4(background_color, 1.0);
    #else
        // Toma el color puro del bloque
        vec4 block_color = texture2D(tex, texcoord) * tint_color;
        
        block_color.rgb *= sky_luma_correction;
    #endif

    #include "/src/writebuffers.glsl"
}

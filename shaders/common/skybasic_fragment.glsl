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

uniform sampler2D gaux4;
uniform float pixel_size_x;
uniform float pixel_size_y;

#ifdef NETHER
    uniform vec3 fogColor;
#endif

#if MC_VERSION < 11604
    uniform mat4 gbufferProjectionInverse;
    uniform float viewWidth;
    uniform float viewHeight;
    uniform float rainStrength;
#endif

/* Ins / Outs */

#if MC_VERSION < 11604
    varying vec3 up_vec;
    varying vec3 hi_sky_color;
    varying vec3 low_sky_color;
#endif

varying vec4 star_data;

/* Utility functions */

#if MC_VERSION < 11604
    #include "/lib/dither.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    #if defined THE_END
        #if MC_VERSION < 11604
            vec4 background_color = vec4(ZENITH_DAY_COLOR, 1.0);
        #endif
        vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);
    #elif defined NETHER  // Unused
        #if MC_VERSION < 11604
            vec4 background_color = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
        #endif
        vec4 block_color = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
    #else
        #if MC_VERSION < 11604
            #if AA_TYPE > 0
                float dither = shifted_r_dither(gl_FragCoord.xy);
            #else
                float dither = dither13(gl_FragCoord.xy);
            #endif

            dither = (dither - .5) * 0.03125;

            vec4 fragpos =
                gbufferProjectionInverse *
                (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
            vec3 nfragpos = normalize(fragpos.xyz);
            float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
            vec4 background_color = vec4(mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, pow(n_u, 0.333))), 1.0);
            background_color.rgb = xyz_to_rgb(background_color.rgb);
        #else

            // Toma el color puro del bloque
            vec4 background_color = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0);
        #endif

        vec4 block_color = star_data;

        block_color = mix(background_color, block_color, block_color);

        #if MC_VERSION >= 11604
            // block_color.a = star_data.a;
        #endif
    #endif

    block_color.rgba = vec4(texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb, clamp(star_data.a * 2.0, 0.0, 1.0));

    #include "/src/writebuffers.glsl"
}

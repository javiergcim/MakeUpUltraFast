#include "/lib/config.glsl"

#ifdef DOF
    const bool colortex1MipmapEnabled = true;
#endif

#ifdef BLOOM
    const bool gaux1MipmapEnabled = true;
#endif

/* Uniforms */

uniform sampler2D colortex1;
uniform sampler2D gaux1;
uniform float inv_aspect_ratio;

#ifdef DOF
    uniform float centerDepthSmooth;
    uniform float pixel_size_x;
    uniform float pixel_size_y;
    uniform float viewWidth;
    uniform float viewHeight;
    uniform float fov_y_inv;
#endif

/* Ins / Outs */

varying vec2 texcoord;

#include "/lib/bloom.glsl"

/* Utility functions */

#if defined BLOOM || defined DOF
    #include "/lib/dither.glsl"
#endif

#ifdef DOF
    #include "/lib/blur.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    vec4 block_color = texture2DLod(colortex1, texcoord, 0);

    #if defined BLOOM || defined DOF
        #if AA_TYPE > 0
            float dither = shifted_dither_makeup(gl_FragCoord.xy);
        #else
            float dither = dither_makeup(gl_FragCoord.xy);
        #endif
    #endif

    #ifdef DOF
        block_color.rgb = noised_blur(block_color, colortex1, texcoord, DOF_STRENGTH, dither);
    #endif

    #ifdef BLOOM
        vec3 bloom = mipmap_bloom(gaux1, texcoord, dither);
        block_color.rgb += bloom;
    #endif

    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
}

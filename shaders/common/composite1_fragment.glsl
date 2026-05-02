#include "/lib/config.glsl"

#ifdef DOF
    const bool colortex1MipmapEnabled = true;
#endif

#ifdef BLOOM
    const bool colortex0MipmapEnabled = true;
#endif

/* Uniforms */

uniform sampler2D colortex1;
uniform sampler2D colortex0;
uniform float aspectRatioInverse;

#ifdef DOF
    uniform float centerDepthSmooth;
    uniform float pixelSizeX;
    uniform float pixelSizeY;
    uniform float viewWidth;
    uniform float viewHeight;
    uniform float fovYInverse;
#endif

#ifdef BLOOM
    uniform float softLod;
#endif

/* Ins / Outs */

varying vec2 texcoord;

#ifdef BLOOM
    #include "/lib/bloom.glsl"
#endif

/* Utility functions */

#if defined BLOOM || defined DOF
    #include "/lib/dither.glsl"
#endif

#ifdef DOF
    #include "/lib/blur.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    vec4 blockColor = texture2DLod(colortex1, texcoord, 0);

    #if defined BLOOM || defined DOF
        #if AA_TYPE > 0
            float dither = shiftedSemiblue(gl_FragCoord.xy);
        #else
            float dither = semiblue(gl_FragCoord.xy);
        #endif
    #endif

    #ifdef DOF
        blockColor.rgb = noisedBlur(blockColor, colortex1, texcoord, DOF_STRENGTH, dither);
    #endif

    #ifdef BLOOM
        vec3 bloom = mipmap_bloom(colortex0, texcoord, dither);
        blockColor.rgb += bloom;
    #endif

    blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = blockColor;
}

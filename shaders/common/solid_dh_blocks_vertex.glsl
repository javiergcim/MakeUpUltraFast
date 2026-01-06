#include "/lib/config.glsl"

/* Color utils */

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform ivec2 eyeBrightnessSmooth;
uniform mat4 dhProjection;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float dayNightMix;
uniform float far;
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;

#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
#endif

#ifdef UNKNOWN_DIM
    uniform sampler2D lightmap;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tintColor;
varying vec3 directLightColor;
varying vec3 candleColor;
varying float directLightStrength;
varying vec3 omniLight;
varying vec4 position;
varying float frog_adjust;

/* Utility functions */

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    float visibleSky;
    vec3 hi_sky_color;

    #include "/src/basiccoords_vertex_dh.glsl"
    #include "/src/position_vertex_dh.glsl"
    #include "/src/hi_sky.glsl"
    #include "/src/light_vertex_dh.glsl"
    #include "/src/fog_vertex_dh.glsl"
}

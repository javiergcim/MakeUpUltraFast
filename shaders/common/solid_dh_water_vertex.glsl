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
varying vec3 fragposition;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 waterNormal;
varying vec3 zenithSkyColor;
varying vec3 horizonSkyColor;
varying vec3 upVector;
varying float visibleSky;
varying vec2 lmcoord;
varying float blockType;
varying float frogAdjust;

/* Utility functions */

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);
    
    #include "/src/basiccoords_vertex_dh.glsl"
    #include "/src/position_vertex_dh.glsl"
    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"
    #include "/src/light_vertex_dh.glsl"
    #include "/src/fog_vertex_dh.glsl"

    vec4 viewSpacePos4D = gl_ModelViewMatrix * gl_Vertex;
    fragposition = viewSpacePos4D.xyz;

    binormal = normalize(gbufferModelView[2].xyz);
    tangent = normalize(gbufferModelView[0].xyz);
    waterNormal = normal;

    upVector = normalize(gbufferModelView[1].xyz);

    if(dhMaterialId == DH_BLOCK_WATER) {  // Water
        blockType = float(DH_BLOCK_WATER);
    }
}

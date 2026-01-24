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

uniform float viewWidth;
uniform float viewHeight;
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float dayNightMix;
uniform float far;
uniform float rainStrength;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjectionInverse;

#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
#endif

#ifdef DYN_HAND_LIGHT
    uniform int heldItemId;
    uniform int heldItemId2;
#endif

#ifdef UNKNOWN_DIM
    uniform sampler2D lightmap;
#endif

#if defined FOLIAGE_V || defined THE_END || defined NETHER
    uniform mat4 gbufferModelView;
#endif

#if defined FOLIAGE_V || defined SHADOW_CASTING || (defined MATERIAL_GLOSS && !defined NETHER)
    uniform mat4 gbufferModelViewInverse;
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
    uniform int worldTime;
    uniform vec3 moonPosition;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if WAVING == 1
    uniform vec3 cameraPosition;
    uniform float frameTimeCounter;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
#endif

#if defined GBUFFER_ENTITIES
    uniform int entityId;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tintColor;
varying float frogAdjust;
varying vec3 directLightColor;
varying vec3 candleColor;
varying float directLightStrength;
varying vec3 omniLight;

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    varying vec3 vWorldPos;
    varying vec3 vNormal;
    varying vec3 vBias;
#endif

#if defined GBUFFER_TERRAIN || defined GBUFFER_HAND || defined GBUFFER_ENTITIES
    varying float isEmissiveEntity;
#endif

#ifdef FOLIAGE_V
    varying float isFoliage;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadowPos;
    varying float shadowDiffuse;
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
    varying vec3 flatNormal;
    varying vec3 viewPositionNormalized;
    varying vec2 lmcoordAlt;
    varying float glossFactor;
    varying float glossPower;
    varying float lumaFactor;
    varying float lumaPower;
#endif

#if defined FOLIAGE_V || defined GBUFFER_TERRAIN || defined GBUFFER_HAND || (defined MATERIAL_GLOSS && !defined NETHER)
    attribute vec4 mc_Entity;
#endif

#if WAVING == 1
    attribute vec2 mc_midTexCoord;
#endif

/* Utility functions */

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

#if WAVING == 1
    #include "/lib/vector_utils.glsl"
#endif

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);
    vec3 zenithSkyColor;
    float visibleSky;

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"
    #include "/src/hi_sky.glsl"
    #include "/src/light_vertex.glsl"
    #include "/src/fog_vertex.glsl"

    #if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
        isEmissiveEntity = 0.0;
        if(mc_Entity.x == ENTITY_NO_SHADOW_FIRE || mc_Entity.x == ENTITY_EMMISIVE || mc_Entity.x == ENTITY_S_EMMISIVE) {
            isEmissiveEntity = 1.0;
        }
    #endif

    // #if defined GBUFFER_ENTITIES
    //     if (entityId == 10102) {
    //         isEmissiveEntity = 1.0;
    //         directLightStrength = 1.0;
    //     }
    // #endif

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
    #endif

    #if defined FOLIAGE_V && !defined NETHER
        #ifdef SHADOW_CASTING
            if (isFoliage > .2) {
                directLightStrength =
                    mix(
                        directLightStrength,
                        farDirectLightStrength,
                        clamp((gl_Position.z / SHADOW_LIMIT) * 2.0 - 0.5, 0.0, 1.0)
                    );
            }
        #endif
    #endif

    #if defined MATERIAL_GLOSS && !defined NETHER
        lumaFactor = 1.0;
        lumaPower = 2.0;
        glossPower = 6.0;
        glossFactor = 1.05;

        if(mc_Entity.x == ENTITY_SAND) {  // Sand-like block
            lumaPower = 4.0;
        } else if(mc_Entity.x == ENTITY_METAL) {  // Metal-like block
            lumaFactor = 1.35;
            lumaPower = -1.0;  // Metallic
            glossPower = 100.0;
        } else if(mc_Entity.x == ENTITY_FABRIC) {  // Fabric-like blocks
            glossPower = 3.0;
            glossFactor = 0.1;
        }

        flatNormal = normal;
        viewPositionNormalized = normalize(viewPosition.xyz);

        lmcoordAlt = lmcoord;    
    #endif

    #if defined GBUFFER_ENTITY_GLOW
        gl_Position.z *= 0.01;
    #endif

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        vNormal = shadowWorldNormal;
        vBias = bias;
    #endif
}

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

uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float dayNightMix;
uniform float far;
uniform float nightVision;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float rainStrength;
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

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tintColor;
varying float frog_adjust;
varying vec3 waterNormal;
varying float block_type;
varying vec4 worldposition;
varying vec3 fragposition;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 directLightColor;
varying vec3 candleColor;
varying float directLightStrength;
varying vec3 omniLight;
varying float visibleSky;
varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    varying vec3 vWorldPos;
    varying vec3 vNormal;
    varying vec3 vBias;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadowPos;
    varying float shadow_diffuse;
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

/* Utility functions */

#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex_water.glsl"

    // Sky color calculation
    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"

    #include "/src/light_vertex.glsl"

    waterNormal = normal;

    tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
    binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));

    // Special entities
    block_type = 0.0;  // 3 - Water, 2 - Glass, ? - Other
    if(mc_Entity.x == ENTITY_WATER) {  // Water
        block_type = 3.0;
    } else if(mc_Entity.x == ENTITY_STAINED) {  // Glass
        block_type = 2.0;
    }

    up_vec = normalize(gbufferModelView[1].xyz);

    #include "/src/fog_vertex.glsl"

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
    #endif

    #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
        #include "/lib/volumetric_clouds_vertex.glsl"
    #endif

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        vNormal = shadow_world_normal;
        vBias = bias;
    #endif
}

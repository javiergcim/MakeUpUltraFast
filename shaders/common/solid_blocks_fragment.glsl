#include "/lib/config.glsl"

// MAIN FUNCTION ------------------

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#endif

/* Uniforms */

uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;
uniform sampler2D tex;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float dayNightMix;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform sampler2D gaux4;

#if defined DISTANT_HORIZONS
    uniform float dhNearPlane;
    uniform float far;
#endif

#if defined GBUFFER_ENTITIES
    uniform int entityId;
    uniform vec4 entityColor;
#endif

#ifdef NETHER
    uniform vec3 fogColor;
#endif

#if defined SHADOW_CASTING
    uniform sampler2DShadow shadowtex1;
    #if defined COLORED_SHADOW
        uniform sampler2DShadow shadowtex0;
        uniform sampler2D shadowcolor0;
    #endif
#endif

uniform float blindness;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
    uniform float darknessLightFactor;
#endif

#ifdef MATERIAL_GLOSS
  // Don't remove
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
    uniform int worldTime;
    uniform vec3 moonPosition;
    uniform vec3 sunPosition;
#endif

#if SHADOW_LOCK > 0 && defined SHADOW_CASTING
    uniform vec3 cameraPosition;
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if defined THE_END || (SHADOW_LOCK > 0 && defined SHADOW_CASTING && !defined NETHER)
    uniform mat4 gbufferModelView;
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

/* Utility functions */

#if (defined SHADOW_CASTING && !defined NETHER) || defined DISTANT_HORIZONS
    #include "/lib/dither.glsl"
#endif

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_frag.glsl"
#endif

#include "/lib/luma.glsl"

#if defined MATERIAL_GLOSS && !defined NETHER
    #include "/lib/material_gloss_fragment.glsl"
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

void main() {
    #if (defined SHADOW_CASTING && !defined NETHER) || defined DISTANT_HORIZONS
        #if AA_TYPE > 0 
            float dither = shiftedDither13(gl_FragCoord.xy);
        #else
            float dither = dither17(gl_FragCoord.xy);
        #endif
    #endif
    // Avoid render in DH transition
    #if defined DISTANT_HORIZONS && !defined GBUFFER_BEACONBEAM
        float t = far - dhNearPlane;
        float sup = t * TRANSITION_DH_SUP;
        float inf = t * TRANSITION_DH_INF;
        float umbral = (gl_FogFragCoord - (dhNearPlane + inf)) / (far - sup - inf - dhNearPlane);
        if(umbral > dither) {
            discard;
            return;
        }
    #endif

    // Toma el color puro del bloque
    #if defined GBUFFER_ENTITIES && BLACK_ENTITY_FIX == 1
        vec4 blockColor = texture2D(tex, texcoord);
        if(blockColor.a < 0.1 && entityId != 10101) {   // Black entities bug workaround
            discard;
        }
        blockColor *= tintColor;
    #else
        vec4 blockColor = texture2D(tex, texcoord) * tintColor;
    #endif

        float block_luma = luma(blockColor.rgb);

        vec3 finalCandleColor = candleColor;
    #if defined GBUFFER_TERRAIN || defined GBUFFER_HAND || defined GBUFFER_ENTITIES
        if(isEmissiveEntity > 0.5) {
            finalCandleColor *= block_luma * 1.5;
        }
    #endif

    #ifdef GBUFFER_WEATHER
        blockColor.a *= .5;
    #endif

    #if defined GBUFFER_ENTITIES
        // Thunderbolt render
        if(entityId == 10101) {
            blockColor.a = 1.0;
        }
    #endif

    #if defined SHADOW_CASTING && !defined NETHER
        #if SHADOW_LOCK > 0
            vec3 offsetVector = vNormal * 0.002;
            vec3 preSnapPos = vWorldPos + offsetVector;
            float texelSize = SHADOW_LOCK;
            vec3 absPos = preSnapPos + cameraPosition;
            // Redondeo al bloque
            vec3 snappedAbsolute = floor(absPos * texelSize) / texelSize;
            snappedAbsolute += 0.5 / texelSize; // Centrar en el texel
            vec3 final_world_pos = (snappedAbsolute - cameraPosition) + vBias;
            vec3 shadow_real_pos = get_shadow_pos(final_world_pos);
        #else
            vec3 shadow_real_pos = shadowPos;
        #endif

        #if defined COLORED_SHADOW
            vec3 shadowValue = get_colored_shadow(shadow_real_pos, dither);
            shadowValue = mix(shadowValue, vec3(1.0), shadowDiffuse);
        #else
            float shadowValue = get_shadow(shadow_real_pos, dither);
            shadowValue = mix(shadowValue, 1.0, shadowDiffuse);
        #endif
    #else
        float shadowValue = abs((dayNightMix * 2.0) - 1.0);
    #endif

    #if defined GBUFFER_BEACONBEAM
        blockColor.rgb *= 1.5;
    #elif defined GBUFFER_ENTITY_GLOW
        blockColor.rgb =
            clamp(vec3(luma(blockColor.rgb)) * vec3(0.75, 0.75, 1.5), vec3(0.3), vec3(1.0));
        vec3 realLight = omniLight +
                (shadowValue * directLightColor * directLightStrength) * (1.0 - (rainStrength * 0.75)) +
                finalCandleColor;
    #else
        #if defined MATERIAL_GLOSS && !defined NETHER
            float final_gloss_power = glossPower;
            block_luma *= lumaFactor;

            if(lumaPower < 0.0) {  // Metallic
                final_gloss_power -= (block_luma * 73.334);
            } else {
                block_luma = pow(block_luma, lumaPower);
            }

            float material_gloss_factor = materialGloss(reflect(viewPositionNormalized, flatNormal), lmcoordAlt, final_gloss_power, flatNormal) * glossFactor;

            float material = material_gloss_factor * block_luma;
            vec3 realLight = omniLight +
                (shadowValue * ((directLightColor * directLightStrength) + (directLightColor * material))) * (1.0 - (rainStrength * 0.75)) +
                finalCandleColor;
        #else
            vec3 realLight = omniLight +
                (shadowValue * directLightColor * directLightStrength) * (1.0 - (rainStrength * 0.75)) +
                finalCandleColor;
        #endif

        blockColor.rgb *= mix(realLight, vec3(1.0), nightVision * 0.125);
        blockColor.rgb *= mix(vec3(1.0, 1.0, 1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);
    #endif

    #if defined GBUFFER_ENTITIES
        if(entityId == 10101) {
            // Thunderbolt render
            blockColor = vec4(1.0, 1.0, 1.0, 0.5);
        } else {
            float entity_poderation = luma(realLight);  // Red damage bright ponderation
            blockColor.rgb = mix(blockColor.rgb, entityColor.rgb, entityColor.a * entity_poderation * 3.0);
        }
    #endif

    #if MC_VERSION < 11300 && defined GBUFFER_TEXTURED
        blockColor.rgb *= 1.5;
    #endif

    #include "/src/finalcolor.glsl"
    #include "/src/writebuffers.glsl"
}

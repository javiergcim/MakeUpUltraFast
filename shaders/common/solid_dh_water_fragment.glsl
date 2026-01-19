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
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform sampler2D gaux4;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D dhDepthTex1;
uniform float frameTimeCounter;
uniform int isEyeInWater;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;
uniform float nightVision;
uniform float rainStrength;
uniform float dayNightMix;
uniform ivec2 eyeBrightnessSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform float dhNearPlane;
uniform float dhFarPlane;
uniform vec3 cameraPosition;
uniform int dhRenderDistance;

#if V_CLOUDS != 0
    uniform sampler2D gaux2;
#endif

#ifdef NETHER
    uniform vec3 fogColor;
#endif

#if defined SHADOW_CASTING && !defined NETHER
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

#include "/lib/projection_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water_dh.glsl"
#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

void main() {
    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);
    vec3 realLight;

    #if AA_TYPE > 0 
        float dither = shiftedRDither(gl_FragCoord.xy);
    #else
        float dither = rDither(gl_FragCoord.xy);
        // dither = 1.0;
    #endif
    
    // Avoid render unnecessary DH
    float t = far - dhNearPlane;
    float inf = t * TRANSITION_DH_INF;
    float visibleDistance = length(position.xyz);
    float d = texture2DLod(depthtex0, vec2(gl_FragCoord.x / viewWidth, gl_FragCoord.y / viewHeight), 0.0).r;
    float linearDepth = ld(d);

    if(linearDepth < 0.9999 || visibleDistance < dhNearPlane + inf) {
        discard;
        return;
    }

    #ifdef VANILLA_WATER
        vec3 waterNormalBase = vec3(0.0, 0.0, 1.0);
    #else
        vec3 mapPos = position.xyz + cameraPosition;
        vec3 waterNormalBase = normal_waves_dh(mapPos.xzy);
    #endif

    vec3 surfaceNormal;
    if(blockType < DH_BLOCK_WATER + 0.5 && blockType > DH_BLOCK_WATER - 0.5) {  // Water
        surfaceNormal = get_normals(waterNormalBase, fragposition);
    } else {
        surfaceNormal = get_normals(vec3(0.0, 0.0, 1.0), fragposition);
    }

    float normalDotEye = dot(surfaceNormal, normalize(fragposition));
    float fresnel = squarePow(1.0 + normalDotEye);

    vec3 reflectWaterVector = reflect(fragposition, surfaceNormal);
    vec3 normalizedReflectWaterVector = normalize(reflectWaterVector);

    vec3 skyColorReflect;
    if(isEyeInWater == 0 || isEyeInWater == 2) {
        skyColorReflect = mix(horizonSkyColor, zenithSkyColor, smoothstep(0.0, 1.0, pow(clamp(dot(normalizedReflectWaterVector, upVector), 0.0001, 1.0), 0.333)));
    } else {
        skyColorReflect = zenithSkyColor * .5 * ((eyeBrightSmoothFloat.y * .8 + 48) * 0.004166666666666667);
    }

    skyColorReflect = xyzToRgb(skyColorReflect);

    #if !defined VANILLA_WATER && WATER_TEXTURE == 1
        vec4 blockColor = vec4(0.1);
        // Synthetic water texture
        vec3 synthesisPosition = (position.xyz + cameraPosition) * 8.0;
        synthesisPosition = floor(synthesisPosition + 0.01);
        float noise = hash13(synthesisPosition);
        noise *= noise;
        noise *= noise;
        noise *= noise;
        float syntheticNoise = (noise * 0.3) + 0.5;
        blockColor.rgb += vec3(syntheticNoise);
    #elif defined VANILLA_WATER
        // Synthetic water texture
        vec3 synthesisPosition = (position.xyz + cameraPosition) * 8.0;
        synthesisPosition = floor(synthesisPosition + 0.01);
        float noise = hash13(synthesisPosition);
        noise *= noise;
        noise *= noise;
        float syntheticNoise = (noise * 0.227) + 0.773;
        vec4 blockColor = vec4(vec3(syntheticNoise), tintColor.a);
    #else
        vec4 blockColor;
    #endif

    if(blockType < DH_BLOCK_WATER + 0.5 && blockType > DH_BLOCK_WATER - 0.5) {  // Water
    #ifdef VANILLA_WATER
        float shadowValue = abs((dayNightMix * 2.0) - 1.0);

        float fresnelTex = luma(blockColor.rgb);

        realLight = omniLight +
            (directLightStrength * shadowValue * directLightColor) * (1.0 - rainStrength * 0.75) +
            candleColor;

        realLight *= (fresnelTex * 2.0) - 0.25;

        blockColor.rgb *= mix(realLight, vec3(1.0), nightVision * .125) * tintColor.rgb;

        blockColor.rgb = water_shader_dh(fragposition, surfaceNormal, blockColor.rgb, skyColorReflect, normalizedReflectWaterVector, fresnel, visibleSky, dither, directLightColor);

        blockColor.a = sqrt(blockColor.a);
    #else
        #if WATER_TEXTURE == 1
            float waterTexture = luma(blockColor.rgb);
        #else
            float waterTexture = 1.0;
        #endif

            realLight = omniLight +
                (directLightStrength * visibleSky * directLightColor) * (1.0 - rainStrength * 0.75) +
                candleColor;

        #if WATER_COLOR_SOURCE == 0
                blockColor.rgb = waterTexture * realLight * WATER_COLOR;
        #elif WATER_COLOR_SOURCE == 1
            blockColor.rgb = 0.3 * waterTexture * realLight * tintColor.rgb;
        #endif

            blockColor = vec4(refraction(fragposition, blockColor.rgb, waterNormalBase), 1.0);

        #if WATER_TEXTURE == 1
            fresnel = clamp(fresnel * (waterTexture * waterTexture + 0.5), 0.0, 1.0);
        #endif

        blockColor.rgb = water_shader_dh(fragposition, surfaceNormal, blockColor.rgb, skyColorReflect, normalizedReflectWaterVector, fresnel, visibleSky, dither, directLightColor);

    #endif

    } else {  // Otros translúcidos

        blockColor = tintColor;

        float shadowValue = abs((dayNightMix * 2.0) - 1.0);

        realLight = omniLight +
            (directLightStrength * shadowValue * directLightColor) * (1.0 - rainStrength * 0.75) +
            candleColor;

        blockColor.rgb *= mix(realLight, vec3(1.0), nightVision * .125);
    }

    #include "/src/finalcolor_dh.glsl"
    #include "/src/writebuffers.glsl"
}

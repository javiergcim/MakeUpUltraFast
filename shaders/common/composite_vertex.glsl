#include "/lib/config.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform float rainStrength;
uniform ivec2 eyeBrightnessSmooth;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    uniform int isEyeInWater;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
    uniform float dayNightMix;
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;
    uniform mat4 gbufferProjection;
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferProjectionInverse;
#endif

uniform sampler2D colortex1;
uniform sampler2D gaux3;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTime;

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 directLightColor;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    varying vec3 volumetricLightColor;  // Flat
#endif

varying float exposure;  // Flat

#if VOL_LIGHT == 1 && !defined NETHER
    varying vec2 lightpos;  // Flat
    varying vec3 astroLightPos;  // Flat
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    varying mat4 modeli_times_projectioni;
#endif

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;

    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);

    directLightColor = dayBlend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    directLightColor = mix(directLightColor, ZENITH_SKY_RAIN_COLOR * luma(directLightColor), rainStrength);

    // Exposure
    float mipmap_level = log2(min(viewWidth, viewHeight)) - 1.0;

    vec3 exposure_col = texture2DLod(colortex1, vec2(0.5), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.25), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.75), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.25, 0.75), mipmap_level).rgb;
    exposure_col += texture2DLod(colortex1, vec2(0.75, 0.25), mipmap_level).rgb;

    exposure = clamp(luma(exposure_col), 0.0005, 100.0);

    float prev_exposure = texture2D(gaux3, vec2(0.5)).r;

    exposure = (exp(-exposure) * 3.03) + 0.6;
    exposure = mix(exposure, prev_exposure, exp(-frameTime * 1.25));

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float vol_attenuation;
        if(isEyeInWater == 0) {
            vol_attenuation = 1.0;
        } else {
            vol_attenuation = 0.1 + (eyeBrightSmoothFloat.y * 0.002);
        }

        volumetricLightColor = dayBlend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR) * 1.2 * vol_attenuation;
    #endif

    #if VOL_LIGHT == 1 && !defined NETHER
        astroLightPos = sunPosition * step(0.5, dayNightMix) * 2.0 + moonPosition;
        vec4 tpos = vec4(astroLightPos, 1.0) * gbufferProjection;
        tpos = vec4(tpos.xyz / tpos.w, 1.0);
        vec2 pos1 = tpos.xy / tpos.z;
        lightpos = pos1 * 0.5 + 0.5;
    #endif

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        modeli_times_projectioni = gbufferModelViewInverse * gbufferProjectionInverse;
    #endif
}

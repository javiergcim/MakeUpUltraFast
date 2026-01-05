#include "/lib/config.glsl"
const bool colortex1MipmapEnabled = true;

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D depthtex0;
uniform int isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
    uniform sampler2D depthtex1;
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;
    uniform float light_mix;
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferModelView;
    uniform float vol_mixer;
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
    uniform float light_mix;
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferModelView;
    uniform float vol_mixer;
    uniform vec3 shadowLightPosition;
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform sampler2DShadow shadowtex1;

    #if defined COLORED_SHADOW
        uniform sampler2DShadow shadowtex0;
        uniform sampler2D shadowcolor0;
    #endif
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 direct_light_color;
varying float exposure;

#if VOL_LIGHT == 1 && !defined NETHER
    varying vec3 vol_light_color;
    varying vec2 lightpos;
    varying vec3 astroLightPos;
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
    varying vec3 vol_light_color;
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    varying mat4 modeli_times_projectioni;
#endif

/* Utility functions */

#include "/lib/basic_utils.glsl"
#include "/lib/depth.glsl"

#ifdef BLOOM
    #include "/lib/luma.glsl"
#endif

#if VOL_LIGHT == 1 && !defined NETHER
    #include "/lib/dither.glsl"
    #include "/lib/volumetric_light.glsl"
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
    #include "/lib/dither.glsl"
    #include "/lib/volumetric_light.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    vec4 blockColor = texture2DLod(colortex1, texcoord, 0);
    float d = texture2DLod(depthtex0, texcoord, 0).r;
    float linearDepth = ld(d);

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    // Depth to distance
    float screen_distance = linearDepth * far * 0.5;

    // Underwater fog
    if(isEyeInWater == 1) {
        float water_absorption = clamp(-pow((-linearDepth + 1.0), (4.0 + (WATER_ABSORPTION * 4.0))) + 1.0, 0.0, 1.0);
        
        blockColor.rgb =
            mix(blockColor.rgb, WATER_COLOR * direct_light_color * ((eye_bright_smooth.y * .8 + 48) * 0.004166666666666667), water_absorption);

    } else if(isEyeInWater == 2) {
        blockColor = mix(blockColor, vec4(1.0, .1, 0.0, 1.0), clamp(sqrt(linearDepth * far * 0.125), 0.0, 1.0));
    }

    #if MC_VERSION >= 11900
        if((blindness > .01 || darknessFactor > .01) && linearDepth > 0.999) {
            blockColor.rgb = vec3(0.0);
        }
    #else
        if(blindness > .01 && linearDepth > 0.999) {
            blockColor.rgb = vec3(0.0);
        }
    #endif

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        #if AA_TYPE > 0
           float dither = shifted_dither17(gl_FragCoord.xy);
        #else
            float dither = r_dither(gl_FragCoord.xy);
        #endif
    #endif

    #if VOL_LIGHT == 1 && !defined NETHER
        #if defined THE_END
            float vol_light = 0.1;
            if(d > 0.9999) {
                vol_light = 0.5;
            }
        #else
            float vol_light = ssGodrays(dither);
        #endif

        vec4 centerFarPlanePos = modeli_times_projectioni * (vec4(0.5, 0.5, 1.0, 1.0) * 2.0 - 1.0);
        vec3 centerEyeDirection = normalize(centerFarPlanePos.xyz);

        vec4 farPlaneClipPos = modeli_times_projectioni * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
        vec3 eyeDirection = normalize(farPlaneClipPos.xyz);

        #if defined THE_END
            // Fixed light source position in sky for intensity calculation
            vec3 auxVector =
                normalize((gbufferModelViewInverse * gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz);
            float volumetricIntensity =
                clamp(dot(centerEyeDirection, auxVector), 0.0, 1.0);

            volumetricIntensity *= clamp(dot(eyeDirection, auxVector), 0.0, 1.0);

            volumetricIntensity *= 0.666;

            blockColor.rgb += (vol_light_color * vol_light * volumetricIntensity * 2.0);
        #else
            // Light source position for depth based godrays intensity calculation
            vec3 auxVector =
                normalize((gbufferModelViewInverse * vec4(astroLightPos, 0.0)).xyz);
            float volumetricIntensity =
                clamp(dot(centerEyeDirection, auxVector), 0.0, 1.0);
            volumetricIntensity *= dot(eyeDirection, auxVector);
            volumetricIntensity =
                pow(clamp(volumetricIntensity, 0.0, 1.0), vol_mixer) * 0.5 * abs(light_mix * 2.0 - 1.0);

            blockColor.rgb =
                mix(blockColor.rgb, vol_light_color * vol_light, volumetricIntensity * (vol_light * 0.5 + 0.5) * (1.0 - rainStrength));
        #endif
    #endif

    #if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
        #if defined COLORED_SHADOW
            vec3 vol_light = get_volumetric_color_light(dither, screen_distance, modeli_times_projectioni);
        #else
            float vol_light = get_volumetric_light(dither, screen_distance, modeli_times_projectioni);
        #endif

        // Volumetric intensity adjustments

        vec4 farPlaneClipPos = modeli_times_projectioni * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
        vec3 eyeDirection = normalize(farPlaneClipPos.xyz);

        #if defined THE_END
            // Fixed light source position in sky for volumetrics intensity calculation (The End)
            float volumetricIntensity = dot(eyeDirection, normalize((gbufferModelViewInverse * gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz));
        #else
            // Light source position for volumetrics intensity calculation
            float volumetricIntensity = dot(eyeDirection, normalize((gbufferModelViewInverse * vec4(shadowLightPosition, 0.0)).xyz));
        #endif

        #if defined THE_END
            volumetricIntensity =
                ((square_pow(clamp((volumetricIntensity + .666667) * 0.6, 0.0, 1.0)) * 0.5));
            blockColor.rgb += (vol_light_color * vol_light * volumetricIntensity * 2.0);
        #else
            volumetricIntensity =
                pow(clamp((volumetricIntensity + 0.5) * 0.666666666666666, 0.0, 1.0), vol_mixer) * 0.6 * abs(light_mix * 2.0 - 1.0);

            blockColor.rgb =
                mix(blockColor.rgb, vol_light_color * vol_light, volumetricIntensity * (vol_light * 0.5 + 0.5) * (1.0 - rainStrength));
        #endif
    #endif

    // Dentro de la nieve
    #ifdef BLOOM
        if(isEyeInWater == 3) {
            blockColor.rgb =
                mix(blockColor.rgb, vec3(0.7, 0.8, 1.0) / exposure, clamp(screen_distance, 0.0, 1.0));
        }
    #else
        if(isEyeInWater == 3) {
            blockColor.rgb =
                mix(blockColor.rgb, vec3(0.85, 0.9, 0.6), clamp(screen_distance, 0.0, 1.0));
        }
    #endif

    #ifdef BLOOM
        // Bloom source
        float bloom_luma = smoothstep(0.85, 1.0, luma(blockColor.rgb * exposure)) * 0.5;

        blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));     
        /* DRAWBUFFERS:146 */
        gl_FragData[0] = blockColor;
        gl_FragData[1] = blockColor * bloom_luma;
        gl_FragData[2] = vec4(exposure, 0.0, 0.0, 0.0);
    #else
        blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));
        /* DRAWBUFFERS:16 */
        gl_FragData[0] = blockColor;
        gl_FragData[1] = vec4(exposure, 0.0, 0.0, 0.0);
    #endif
}
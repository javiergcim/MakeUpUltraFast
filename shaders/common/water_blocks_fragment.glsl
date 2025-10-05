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
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform float frameTimeCounter;
uniform int isEyeInWater;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;
uniform float nightVision;
uniform float rainStrength;
uniform float light_mix;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D gaux4;

#if defined DISTANT_HORIZONS
    uniform float dhNearPlane;
    uniform float dhFarPlane;
    uniform sampler2D dhDepthTex1;
#endif

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

#ifdef CLOUD_REFLECTION
  // Don't remove
#endif

#if defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER
    uniform vec3 cameraPosition;
    uniform mat4 gbufferModelViewInverse;
#endif

uniform float blindness;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
    uniform float darknessLightFactor;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 water_normal;
varying float block_type;
varying vec4 worldposition;
varying vec3 fragposition;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying float visible_sky;
varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadow_pos;
    varying float shadow_diffuse;
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

/* Utility functions */

#include "/lib/projection_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_frag.glsl"
#endif

#include "/lib/luma.glsl"

#if defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER
    #include "/lib/volumetric_clouds.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    #if SHADOW_TYPE == 1 || defined DISTANT_HORIZONS || (defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER) || SSR_TYPE > 0
        #if AA_TYPE > 0
            float dither = shifted_r_dither(gl_FragCoord.xy);
        #else
            float dither = r_dither(gl_FragCoord.xy);
        #endif
    #else
        float dither = 1.0;
    #endif

    vec4 block_color;
    vec3 real_light;

    #ifdef VANILLA_WATER
        vec3 water_normal_base = vec3(0.0, 0.0, 1.0);
    #else
        vec3 water_normal_base = normal_waves(worldposition.xzy);
    #endif
    
    vec3 surface_normal;
    if(block_type > 2.5) {  // Water
        surface_normal = get_normals(water_normal_base, fragposition);
    } else {
        surface_normal = get_normals(vec3(0.0, 0.0, 1.0), fragposition);
    }

    float normal_dot_eye = dot(surface_normal, normalize(fragposition));
    float fresnel = square_pow(1.0 + normal_dot_eye);

    vec3 reflect_water_vec = reflect(fragposition, surface_normal);
    vec3 norm_reflect_water_vec = normalize(reflect_water_vec);

    vec3 sky_color_reflect;
    if(isEyeInWater == 0 || isEyeInWater == 2) {
        sky_color_reflect = mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, pow(clamp(dot(norm_reflect_water_vec, up_vec), 0.0001, 1.0), 0.333)));
    } else {
        sky_color_reflect = hi_sky_color * .5 * ((eye_bright_smooth.y * .8 + 48) * 0.004166666666666667);
    }

    sky_color_reflect = xyz_to_rgb(sky_color_reflect);

    #if defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER
        sky_color_reflect = get_cloud(normalize((gbufferModelViewInverse * vec4(reflect_water_vec * far, 1.0)).xyz), sky_color_reflect, 0.0, dither, worldposition.xyz, int(CLOUD_STEPS_AVG * 0.5), umbral, cloud_color, dark_cloud_color);
    #endif
    if(block_type > 2.5) {  // Water
        #ifdef VANILLA_WATER
            block_color = texture2D(tex, texcoord);
            #if defined SHADOW_CASTING && !defined NETHER
                #if defined COLORED_SHADOW
                    vec3 shadow_c = get_colored_shadow(shadow_pos, dither);
                    shadow_c = mix(shadow_c, vec3(1.0), shadow_diffuse);
                #else
                    float shadow_c = get_shadow(shadow_pos, dither);
                    shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
                #endif
            #else
                float shadow_c = abs((light_mix * 2.0) - 1.0);
            #endif

            float fresnel_tex = luma(block_color.rgb);

            real_light = omni_light +
                (direct_light_strength * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
                candle_color;

            real_light *= (fresnel_tex * 2.0) - 0.25;

            block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125) * tint_color.rgb;

            block_color.rgb = water_shader(fragposition, surface_normal, block_color.rgb, sky_color_reflect, norm_reflect_water_vec, fresnel, visible_sky, dither, direct_light_color);

            block_color.a = sqrt(block_color.a);
        #else
            #if WATER_TEXTURE == 1
                block_color = texture2D(tex, texcoord);
                float water_texture = luma(block_color.rgb);
            #else
                float water_texture = 1.0;
            #endif

            real_light = omni_light +
                (direct_light_strength * visible_sky * direct_light_color) * (1.0 - rainStrength * 0.75) +
                candle_color;

            #if WATER_COLOR_SOURCE == 0
                block_color.rgb = water_texture * real_light * WATER_COLOR;
            #elif WATER_COLOR_SOURCE == 1
                block_color.rgb = 0.3 * water_texture * real_light * tint_color.rgb;
            #endif

            block_color = vec4(refraction(fragposition, block_color.rgb, water_normal_base), 1.0);

            #if WATER_TEXTURE == 1
                water_texture += 0.25;
                water_texture *= water_texture;
                water_texture *= water_texture;
                fresnel = clamp(fresnel * (water_texture), 0.0, 1.0);
            #endif

            block_color.rgb = water_shader(fragposition, surface_normal, block_color.rgb, sky_color_reflect, norm_reflect_water_vec, fresnel, visible_sky, dither, direct_light_color);
            
        #endif

    } else {  // Otros translúcidos
        block_color = texture2D(tex, texcoord);

        block_color *= tint_color;

        #if defined SHADOW_CASTING && !defined NETHER
        #if defined COLORED_SHADOW
            vec3 shadow_c = get_colored_shadow(shadow_pos, dither);
            shadow_c = mix(shadow_c, vec3(1.0), shadow_diffuse);
        #else
            float shadow_c = get_shadow(shadow_pos, dither);
            shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
        #endif
        #else
            float shadow_c = abs((light_mix * 2.0) - 1.0);
        #endif

        real_light = omni_light +
            (direct_light_strength * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
            candle_color;

        block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

        if(block_type > 1.5) {  // Glass
            block_color = cristal_shader(fragposition, water_normal, block_color, sky_color_reflect, fresnel * fresnel, visible_sky, dither, direct_light_color);
        }
    }

    // Avoid render in DH transition
    #ifdef DISTANT_HORIZONS
        float t = far - dhNearPlane;
        float sup = t * TRANSITION_DH_SUP;
        float inf = t * TRANSITION_DH_INF;
        float draw_umbral = (gl_FogFragCoord - (dhNearPlane + inf)) / (far - sup - inf - dhNearPlane);
        if(draw_umbral > dither) {
            discard;
            return;
        }
    #endif

    #include "/src/finalcolor.glsl"
    #include "/src/writebuffers.glsl"
}

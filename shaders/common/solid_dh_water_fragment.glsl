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
uniform float light_mix;
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
varying vec4 tint_color;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying vec4 position;
varying vec3 fragposition;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 water_normal;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;
varying vec3 up_vec;
varying float visible_sky;
varying vec2 lmcoord;
varying float block_type;
varying float frog_adjust;

/* Utility functions */

#include "/lib/projection_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water_dh.glsl"
#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

void main() {
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    vec3 real_light;

    #if AA_TYPE > 0 
        float dither = shifted_r_dither(gl_FragCoord.xy);
    #else
        float dither = r_dither(gl_FragCoord.xy);
        // dither = 1.0;
    #endif
    
    // Avoid render unnecessary DH
    float t = far - dhNearPlane;
    float inf = t * TRANSITION_DH_INF;
    float view_dist = length(position.xyz);
    float d = texture2DLod(depthtex0, vec2(gl_FragCoord.x / viewWidth, gl_FragCoord.y / viewHeight), 0.0).r;
    float linear_d = ld(d);

    if(linear_d < 0.9999 || view_dist < dhNearPlane + inf) {
        discard;
        return;
    }

    #ifdef VANILLA_WATER
        vec3 water_normal_base = vec3(0.0, 0.0, 1.0);
    #else
        vec3 world_pos = position.xyz + cameraPosition;
        vec3 water_normal_base = normal_waves_dh(world_pos.xzy);
    #endif

    vec3 surface_normal;
    if(block_type < DH_BLOCK_WATER + 0.5 && block_type > DH_BLOCK_WATER - 0.5) {  // Water
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

    #if !defined VANILLA_WATER && WATER_TEXTURE == 1
        vec4 block_color = vec4(0.1);
        // Synthetic water texture
        vec3 synth_pos = (position.xyz + cameraPosition) * 8.0;
        synth_pos = floor(synth_pos + 0.01);
        float noise = hash13(synth_pos);
        noise *= noise;
        noise *= noise;
        noise *= noise;
        float synth_noise = (noise * 0.3) + 0.5;
        block_color.rgb += vec3(synth_noise);
    #elif defined VANILLA_WATER
        // Synthetic water texture
        vec3 synth_pos = (position.xyz + cameraPosition) * 8.0;
        synth_pos = floor(synth_pos + 0.01);
        float noise = hash13(synth_pos);
        noise *= noise;
        noise *= noise;
        float synth_noise = (noise * 0.227) + 0.773;
        vec4 block_color = vec4(vec3(synth_noise), tint_color.a);
    #else
        vec4 block_color;
    #endif

    if(block_type < DH_BLOCK_WATER + 0.5 && block_type > DH_BLOCK_WATER - 0.5) {  // Water
    #ifdef VANILLA_WATER
        float shadow_c = abs((light_mix * 2.0) - 1.0);

        float fresnel_tex = luma(block_color.rgb);

        real_light = omni_light +
            (direct_light_strength * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
            candle_color;

        real_light *= (fresnel_tex * 2.0) - 0.25;

        block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125) * tint_color.rgb;

        block_color.rgb = water_shader_dh(fragposition, surface_normal, block_color.rgb, sky_color_reflect, norm_reflect_water_vec, fresnel, visible_sky, dither, direct_light_color);

        block_color.a = sqrt(block_color.a);
    #else
        #if WATER_TEXTURE == 1
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
            fresnel = clamp(fresnel * (water_texture * water_texture + 0.5), 0.0, 1.0);
        #endif

        block_color.rgb = water_shader_dh(fragposition, surface_normal, block_color.rgb, sky_color_reflect, norm_reflect_water_vec, fresnel, visible_sky, dither, direct_light_color);

    #endif

    } else {  // Otros translúcidos

        block_color = tint_color;

        float shadow_c = abs((light_mix * 2.0) - 1.0);

        real_light = omni_light +
            (direct_light_strength * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
            candle_color;

        block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);
    }

    #include "/src/finalcolor_dh.glsl"
    #include "/src/writebuffers.glsl"
}

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

uniform sampler2D colortex1;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D gaux3;
uniform int frameCounter;

#if V_CLOUDS != 0
    uniform sampler2D gaux2;
#endif

#ifdef NETHER
    uniform vec3 fogColor;
#endif

#if AO == 1
    uniform float inv_aspect_ratio;
    uniform float fov_y_inv;
#endif

#if V_CLOUDS != 0 && !defined UNKNOWN_DIM
    uniform sampler2D noisetex;
    uniform vec3 cameraPosition;
    uniform vec3 sunPosition;

    #if defined DISTANT_HORIZONS
        uniform sampler2D dhDepthTex0;
        uniform float dhNearPlane;
        uniform float dhFarPlane;
        uniform float viewWidth;
        uniform float viewHeight;
    #endif
#endif

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float pixel_size_x;
uniform float pixel_size_y;

#if AO == 1 || (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
    uniform mat4 gbufferProjection;
    uniform float frameTimeCounter;
    uniform sampler2D colortex2;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 up_vec;  // Flat

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

#if AO == 1
    varying float fog_density_coeff;
#endif

/* Utility functions */ 

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

#ifdef DISTANT_HORIZONS
    #include "/lib/depth_dh.glsl"
#endif

#if AO == 1 || (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
    #include "/lib/dither.glsl"
#endif

#if AO == 1
    #include "/lib/ao.glsl"
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
    #include "/lib/projection_utils.glsl"

    #ifdef THE_END
        #include "/lib/volumetric_clouds_end.glsl"
    #else
        #include "/lib/volumetric_clouds.glsl"
    #endif
#endif

// MAIN FUNCTION ------------------

void main() {
    vec4 block_color = texture2DLod(colortex1, texcoord, 0);
    float d = texture2DLod(depthtex0, texcoord, 0).r;
    float linear_d = ld(d);

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    vec3 view_vector = vec3(1.0);

    #if AO == 1 || (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
        #if AA_TYPE > 0
            float dither = shifted_dither_makeup(gl_FragCoord.xy);
        #else
            float dither = dither_makeup(gl_FragCoord.xy);
        #endif
    #endif

    #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
        if(linear_d > 0.9999) {  // Only sky
            vec4 world_pos = gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
            view_vector = normalize(world_pos.xyz);

            #ifdef THE_END
                float bright = dot(view_vector, vec3(0.0, 0.89442719, 0.4472136));
                bright = clamp((bright * 2.0) - 1.0, 0.0, 1.0);
                bright *= bright * bright * bright;
            #else
                float bright = dot(view_vector, normalize((gbufferModelViewInverse * vec4(sunPosition, 0.0)).xyz));
                bright = clamp(bright * bright * bright, 0.0, 1.0);
            #endif

            #ifdef THE_END
                #ifdef END_CLOUDS
                    block_color.rgb = get_end_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG);
                #endif
            #else
                block_color.rgb = get_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG, umbral, cloud_color, dark_cloud_color);
            #endif
        }

    #else
        #if defined NETHER
            #if !defined DISTANT_HORIZONS
                if(linear_d > 0.9999) {  // Only sky
                    block_color = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
                }
            #endif
        #elif !defined NETHER && !defined THE_END
            if(linear_d > 0.9999 && isEyeInWater == 1) {  // Only sky and water
                vec4 screen_pos = vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0);
                vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

                vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
                view_vector = normalize(world_pos.xyz);
            }
        #endif
    #endif

    #if AO == 1
        // AO distance attenuation
        #if defined NETHER
            if(NETHER_FOG_DISTANCE == 0) {
                linear_d = sqrt(linear_d);
            } else {
                float screen_distance = 2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));
                linear_d = screen_distance / NETHER_SIGHT;
            }
        #endif
        float ao_att =
            pow(clamp(linear_d * 1.6, 0.0, 1.0), mix(fog_density_coeff, 1.0, rainStrength));

        float final_ao = mix(dbao(dither), 1.0, ao_att);
        block_color.rgb *= final_ao;
    #endif

    #if defined THE_END || defined NETHER
        #define NIGHT_CORRECTION 1.0
    #else
        #define NIGHT_CORRECTION day_blend_float(1.0, 1.0, 0.1)
    #endif

    // Underwater sky
    if(isEyeInWater == 1) {
        if(linear_d > 0.9999) {
            block_color.rgb = mix(NIGHT_CORRECTION * WATER_COLOR * ((eye_bright_smooth.y * .8 + 48) * 0.004166666666666667), block_color.rgb, max(clamp(view_vector.y - 0.1, 0.0, 1.0), rainStrength));
        }
    }

    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
    /* DRAWBUFFERS:14 */
    gl_FragData[0] = vec4(block_color.rgb, d);
    gl_FragData[1] = block_color;
}
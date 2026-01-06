#include "/lib/config.glsl"

/* Uniforms */

uniform float dayNightMix;
uniform float nightVision;
uniform float rainStrength;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D gaux4;
uniform float dhNearPlane;
uniform float dhFarPlane;
uniform float far;
uniform vec3 cameraPosition;
uniform int dhRenderDistance;

#ifdef NETHER
    uniform vec3 fogColor;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tintColor;
varying vec3 directLightColor;
varying vec3 candleColor;
varying float directLightStrength;
varying vec3 omniLight;
varying vec4 position;
varying float frog_adjust;

/* Utility functions */

#include "/lib/luma.glsl"
#include "/lib/dither.glsl"

// MAIN FUNCTION ------------------

void main() {
    #if AA_TYPE > 0 
        float dither = shiftedRDither(gl_FragCoord.xy);
    #else
        float dither = rDither(gl_FragCoord.xy);
    #endif

    // Avoid render unnecessary DH
    float t = far - dhNearPlane;
    float inf = t * TRANSITION_DH_INF;
    float view_dist = length(position.xyz);
    if(view_dist < dhNearPlane + inf) {
        discard;
        return;
    }

    vec4 blockColor = tintColor;
    
    // Synthetic pseudo-texture
    vec3 synth_pos = (position.xyz + cameraPosition) * 6.0;
    synth_pos = floor(synth_pos + 0.01);
    float synth_noise = (hash13(synth_pos) - 0.5) * 0.1;
    blockColor.rgb += vec3(synth_noise);
    blockColor.rgb = clamp(blockColor.rgb, vec3(0.0), vec3(1.0));

    float block_luma = luma(tintColor.rgb);

    vec3 final_candle_color = candleColor;

    float shadow_c = abs((dayNightMix * 2.0) - 1.0);

    vec3 real_light =
        omniLight +
        (shadow_c * directLightColor * directLightStrength) * (1.0 - (rainStrength * 0.75)) +
        final_candle_color;

    blockColor.rgb *= mix(real_light, vec3(1.0), nightVision * 0.125);
    blockColor.rgb *= mix(vec3(1.0, 1.0, 1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);

    blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));

    #include "/src/finalcolor_dh.glsl"
    #include "/src/writebuffers.glsl"
}

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

uniform ivec2 eyeBrightnessSmooth;
uniform mat4 dhProjection;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float light_mix;
uniform float far;
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;

#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
#endif

#ifdef UNKNOWN_DIM
    uniform sampler2D lightmap;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
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

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    
    #include "/src/basiccoords_vertex_dh.glsl"
    #include "/src/position_vertex_dh.glsl"
    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"
    #include "/src/light_vertex_dh.glsl"
    #include "/src/fog_vertex_dh.glsl"

    vec4 position2 = gl_ModelViewMatrix * gl_Vertex;
    fragposition = position2.xyz;

    binormal = normalize(gbufferModelView[2].xyz);
    tangent = normalize(gbufferModelView[0].xyz);
    water_normal = normal;

    up_vec = normalize(gbufferModelView[1].xyz);

    if(dhMaterialId == DH_BLOCK_WATER) {  // Water
        block_type = float(DH_BLOCK_WATER);
    }
}

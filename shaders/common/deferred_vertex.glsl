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

uniform mat4 gbufferModelView;

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    uniform float rainStrength;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 upVector;

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloudColor;
    varying vec3 darkCloudColor;
#endif

#if AO == 1
    varying float fogDensityCoeff;
#endif

/* Utility functions */

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    #include "/lib/luma.glsl"
#endif

    // MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;
    upVector = normalize(gbufferModelView[1].xyz);

    #if AO == 1
        #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
            fogDensityCoeff = FOG_DENSITY * FOG_ADJUST;
        #else
            fogDensityCoeff = dayBlendFloat(FOG_SUNSET, FOG_DAY, FOG_NIGHT) * FOG_ADJUST;
        #endif
    #endif

    #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
        #include "/lib/volumetric_clouds_vertex.glsl"
    #endif
}
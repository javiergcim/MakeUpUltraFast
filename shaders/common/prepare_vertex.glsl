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
uniform float rainStrength;

/* Ins / Outs */

varying vec3 upVector;
varying vec3 zenithSkyColor;
varying vec3 horizonSkyColor;

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"

    upVector = normalize(gbufferModelView[1].xyz);
}

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

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"

    up_vec = normalize(gbufferModelView[1].xyz);
}

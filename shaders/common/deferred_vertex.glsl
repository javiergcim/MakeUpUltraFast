/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform mat4 gbufferModelView;
uniform float rainStrength;

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  uniform float rainStrength;
#endif

varying vec2 texcoord;
varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  varying float umbral;
  varying vec3 cloud_color;
  varying vec3 dark_cloud_color;
#endif

// #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  #include "/lib/luma.glsl"
// #endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;
  up_vec = normalize(gbufferModelView[1].xyz);

  #include "/lib/sky_color_vertex.glsl"

  #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    #include "/lib/volumetric_clouds_vertex.glsl"
  #endif
}
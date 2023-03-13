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

varying vec2 texcoord;
varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  varying float umbral;
  varying vec3 cloud_color;
  varying vec3 dark_cloud_color;
#endif

#if AO == 1
 varying float fog_density_coeff;
#endif

#include "/lib/luma.glsl"

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;
  up_vec = normalize(gbufferModelView[1].xyz);

  #include "/src/sky_color_vertex.glsl"

  #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    #include "/lib/volumetric_clouds_vertex.glsl"
  #endif

  #if AO == 1
    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
      fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
    #else
      fog_density_coeff = day_blend_float(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT
      ) * FOG_ADJUST;
    #endif
  #endif
}
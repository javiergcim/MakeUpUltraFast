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

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  uniform float rainStrength;
#endif

in vec3 vaPosition;

out vec2 texcoord;
flat out vec3 up_vec;

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  flat out float umbral;
  flat out vec3 cloud_color;
  flat out vec3 dark_cloud_color;
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);
  texcoord = vaPosition.xy;
  up_vec = normalize(gbufferModelView[1].xyz);

  #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    #include "/lib/volumetric_clouds_vertex.glsl"
  #endif
}


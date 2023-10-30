#include "/lib/config.glsl"

#if MC_VERSION < 11604
  #ifdef THE_END
    #include "/lib/color_utils_end.glsl"
  #elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
  #else
    #include "/lib/color_utils.glsl"
  #endif
#endif

/* Config, uniforms, ins, outs */
uniform mat4 gbufferModelView;

#if MC_VERSION < 11604
  uniform float rainStrength;
#endif

#if MC_VERSION < 11604
  varying vec3 up_vec;
  varying vec3 hi_sky_color;
  varying vec3 low_sky_color;
#endif

varying vec4 star_data;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

#if MC_VERSION < 11604
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

  #if AA_TYPE > 0
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif

  star_data =
    vec4(
      float(
        gl_Color.r == gl_Color.g &&
        gl_Color.g == gl_Color.b &&
        gl_Color.r > 0.0
      ) * gl_Color.r
    );

  #if MC_VERSION < 11604
    up_vec = normalize(gbufferModelView[1].xyz);

    #include "/src/sky_color_vertex.glsl"
  #endif
}

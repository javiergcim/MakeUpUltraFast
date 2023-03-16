/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform mat4 gbufferModelView;
uniform float rainStrength;

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;

#include "/lib/luma.glsl"

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

  #include "/src/sky_color_vertex.glsl"
  
  up_vec = normalize(gbufferModelView[1].xyz);
}

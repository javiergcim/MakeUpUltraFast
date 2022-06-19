/* Config, uniforms, ins, outs */
#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

// uniform sampler2D colortex1;
uniform sampler2D gaux3;
uniform float viewWidth;

varying vec2 texcoord;
varying float exposure;

 #include "/lib/luma.glsl"

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

  // Tonemaping ---
  // x: Block, y: Sky ---
  #if !defined UNKNOWN_DIM
    exposure = texture2D(gaux3, vec2(0.5)).r;
  #else
    exposure = 1.0;
  #endif
}

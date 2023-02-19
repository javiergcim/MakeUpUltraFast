/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform ivec2 eyeBrightnessSmooth;

#if !defined SIMPLE_AUTOEXP
  uniform sampler2D gaux3;
  uniform float viewWidth;
#endif

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
    #if defined SIMPLE_AUTOEXP

      float exposure_coef = day_blend_float(
        EXPOSURE_SUNSET,
        EXPOSURE_DAY,
        EXPOSURE_NIGHT
      );

      float candle_bright = eye_bright_smooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)

      exposure =
        ((eye_bright_smooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

      // Map from 1.0 - 0.0 to 1.0 - 3.4
      exposure = (exposure * -2.4) + 3.4;
    #else
      exposure = texture2D(gaux3, vec2(0.5)).r;
    #endif
  #else
    exposure = 1.0;
  #endif
}

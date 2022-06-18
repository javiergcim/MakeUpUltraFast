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
    // float candle_bright = eye_bright_smooth.x * 0.0003125;
    // float exposure_coef = day_blend_float(
    //   EXPOSURE_MIDDLE,
    //   EXPOSURE_DAY,
    //   EXPOSURE_NIGHT
    // );
    // exposure =
    //   ((eye_bright_smooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

    // exposure = length(texture2D(colortex1, vec2(0.5), log2(viewWidth * 0.4)).rgb);
    // exposure = luma(texture2D(colortex1, vec2(0.5), log2(viewWidth * 0.4)).rgb);
    // float prev_exposure = texture2D(gaux3, vec2(0.5)).r;

    // exposure = (exp(-exposure * 7.0) * 3.0) + 0.99;
    // // exposure = 1.0;

    // exposure = mix(exposure, prev_exposure, 0.99);
    exposure = texture2D(gaux3, vec2(0.5)).r;
  #else
    exposure = 1.0;
  #endif

  // Map from 1.0 - 0.0 to 1.0 - 3.4
  // exposure = (exposure * -2.4) + 3.4;
}

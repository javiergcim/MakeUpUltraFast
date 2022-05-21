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

in vec3 vaPosition;

out vec2 texcoord;
flat out float exposure;

void main() {
  gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);
  texcoord = vaPosition.xy;

  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

  // Tonemaping ---
  // x: Block, y: Sky ---
  #if !defined UNKNOWN_DIM
    float candle_bright = eye_bright_smooth.x * 0.0003125;
    float exposure_coef = day_blend_float(
      EXPOSURE_MIDDLE,
      EXPOSURE_DAY,
      EXPOSURE_NIGHT
    );
    exposure =
      ((eye_bright_smooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;
  #else
    exposure = 1.0;
  #endif

  // Map from 1.0 - 0.0 to 1.0 - 3.4
  exposure = (exposure * -2.4) + 3.4;
}

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
  // gl_Position = (projectionMatrix * modelViewMatrix) * vec4(vaPosition, 1.0);  // Alt
  gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);
  // texcoord = vec4(vaUV0, 0.0, 1.0).xy;  // Alt
  texcoord = vaPosition.xy;

  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

  // Tonemaping ---
  // x: Block, y: Sky ---
  float candle_bright = eye_bright_smooth.x * 0.0003125;
  float exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );
  exposure =
    ((eye_bright_smooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

  // Map from 1.0 - 0.0 to 1.0 - 3.4
  exposure = (exposure * -2.4) + 3.4;
}

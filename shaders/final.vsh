#version 130
/* MakeUp - final.fsh
Render: Final renderer

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

// Varyings (per thread shared variables)
out vec2 texcoord;
flat out float exposure;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  // Tonemaping ---
  // x: Block, y: Sky ---
  float candle_bright = eyeBrightnessSmooth.x * 0.0003125;
  float exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );
  exposure =
    ((eyeBrightnessSmooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

  // Map from 1.0 - 0.0 to 1.0 - 3.6
  exposure = (exposure * -2.6) + 3.6;
}

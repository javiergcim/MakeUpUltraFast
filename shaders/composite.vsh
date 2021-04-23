#version 130
/* MakeUp - composite.fsh
Render: DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
#ifdef BLOOM
  uniform ivec2 eyeBrightnessSmooth;
  uniform int current_hour_floor;
  uniform int current_hour_ceil;
  uniform float current_hour_fract;
#endif

// Varyings (per thread shared variables)
out vec2 texcoord;

#ifdef BLOOM
  flat out float exposure;
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  #ifdef BLOOM
    // Exposure
    float candle_bright = eyeBrightnessSmooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)
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
  #endif
}

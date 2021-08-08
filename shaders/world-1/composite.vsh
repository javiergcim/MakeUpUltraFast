#version 120
/* MakeUp - composite.vsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"
#include "/lib/color_utils_nether.glsl"

// 'Global' constants from system
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#ifdef BLOOM
  uniform ivec2 eyeBrightnessSmooth;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#ifdef BLOOM
  varying float exposure;  // Flat
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  float exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );

  #ifdef BLOOM
    // Exposure
    float candle_bright = eyeBrightnessSmooth.x * 0.0003125;  // (0.004166666666666667 * 0.075)

    exposure =
      ((eyeBrightnessSmooth.y * 0.004166666666666667) * exposure_coef) + candle_bright;

    // Map from 1.0 - 0.0 to 1.0 - 3.4
    exposure = (exposure * -2.4) + 3.4;
  #endif
}

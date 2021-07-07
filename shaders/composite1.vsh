#version 120
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

#ifdef VOL_LIGHT
  uniform float rainStrength;
  uniform ivec2 eyeBrightnessSmooth;
  uniform float current_hour_fract;
  uniform int current_hour_floor;
  uniform int current_hour_ceil;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#ifdef VOL_LIGHT
  varying vec3 current_fog_color;
#endif

#ifdef VOL_LIGHT
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  #ifdef VOL_LIGHT
    // Fog color calculation
    float fog_mix_level = mix(
      fog_color_mix[current_hour_floor],
      fog_color_mix[current_hour_ceil],
      current_hour_fract
      );

    // Fog intensity calculation
    float fog_density_coeff = mix(
      fog_density[current_hour_floor],
      fog_density[current_hour_ceil],
      current_hour_fract
      );

    float fog_intensity_coeff = max(
      // visible_sky,
      1.0,
      eyeBrightnessSmooth.y * 0.004166666666666667
    );

    vec3 hi_sky_color = day_blend(
      HI_MIDDLE_COLOR,
      HI_DAY_COLOR,
      HI_NIGHT_COLOR
      );

    hi_sky_color = mix(
      hi_sky_color,
      HI_SKY_RAIN_COLOR * luma(hi_sky_color),
      rainStrength
    );

    vec3 low_sky_color = day_blend(
      LOW_MIDDLE_COLOR,
      LOW_DAY_COLOR,
      LOW_NIGHT_COLOR
      );

    low_sky_color = mix(
      low_sky_color,
      LOW_SKY_RAIN_COLOR * luma(low_sky_color),
      rainStrength
    );

    current_fog_color =
      mix(hi_sky_color, low_sky_color, fog_mix_level) * fog_intensity_coeff;

    // current_fog_color = vec3(1.0);
  #endif
}

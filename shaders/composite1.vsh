#version 120
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

#if defined VOL_LIGHT && defined SHADOW_CASTING
  uniform float rainStrength;
  uniform float current_hour_fract;
  uniform int current_hour_floor;
  uniform int current_hour_ceil;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if defined VOL_LIGHT && defined SHADOW_CASTING
  varying vec3 vol_light_color;
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING
  #include "/lib/luma.glsl"
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  texcoord = gl_MultiTexCoord0.xy;

  #if defined VOL_LIGHT && defined SHADOW_CASTING
    // Fog color calculation
    float fog_mix_level = mix(
      fog_color_mix[current_hour_floor],
      fog_color_mix[current_hour_ceil],
      current_hour_fract
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

    vol_light_color =
      mix(hi_sky_color, low_sky_color, fog_mix_level);


    // // Calculamos color de luz directa
    // vol_light_color = day_blend(
    //   AMBIENT_MIDDLE_COLOR,
    //   AMBIENT_DAY_COLOR,
    //   AMBIENT_NIGHT_COLOR
    //   );
  #endif
}

float fog_mix_level;
float fog_intensity_coeff;  // Avoids fog in caves
if (isEyeInWater == 0) { // In the air
  // Fog color calculation
  fog_mix_level = mix(
    fog_color_mix[current_hour_floor],
    fog_color_mix[current_hour_ceil],
    current_hour_fract
    );
  // Fog intensity calculation
  fog_density_coeff = mix(
    fog_density[current_hour_floor],
    fog_density[current_hour_ceil],
    current_hour_fract
    );

  #ifdef NETHER
    fog_intensity_coeff = 1.0;
    current_fog_color = gl_Fog.color.rgb;
  #elif defined THE_END
    fog_intensity_coeff = 1.0;
    current_fog_color = gl_Fog.color.rgb;
  #else
    fog_intensity_coeff = max(
      visible_sky,
      eyeBrightnessSmooth.y * 0.004166666666666667
    );

    #if MAKEUP_COLOR == 1
      vec3 low_sky_color = mix(
        low_sky_color_array[current_hour_floor],
        low_sky_color_array[current_hour_ceil],
        current_hour_fract
      );

      low_sky_color = mix(
        low_sky_color,
        LOW_SKY_RAIN_COLOR * luma(low_sky_color),
        rainStrength
      );
    #else
      vec3 low_sky_color = gl_Fog.color.rgb;
    #endif

    current_fog_color = mix(hi_sky_color, low_sky_color, fog_mix_level);
  #endif

  frog_adjust = pow(
    (gl_FogFragCoord / far) * fog_intensity_coeff,
    mix(fog_density_coeff, .5, rainStrength)
  );
}

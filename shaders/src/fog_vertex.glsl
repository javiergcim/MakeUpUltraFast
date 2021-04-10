#ifndef NETHER
  #ifndef THE_END
    // float fog_mix_level;
    // float fog_intensity_coeff;  // Avoids fog in caves

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
      visible_sky,
      eyeBrightnessSmooth.y * 0.004166666666666667
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

    frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
      mix(fog_density_coeff, .5, rainStrength)
    );
  #else
    current_fog_color = HI_DAY_COLOR;
    // fog_density_coeff = 1.0;
    frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0),
      .5
    );
  #endif
#endif

#ifndef NETHER
  #ifndef THE_END
    float fog_mix_level;
    float fog_intensity_coeff;  // Avoids fog in caves

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

    fog_intensity_coeff = max(
      visible_sky,
      eyeBrightnessSmooth.y * 0.004166666666666667
    );

    #if MAKEUP_COLOR == 1
      // vec3 low_sky_color =
      //     texture2D(gaux3, vec2(LOW_SKY_X, current_hour)).rgb;

      vec3 low_sky_color = day_color_mixer(
        LOW_MIDDLE_COLOR,
        LOW_DAY_COLOR,
        LOW_NIGHT_COLOR,
        day_moment
        );

      low_sky_color = mix(
        low_sky_color,
        LOW_SKY_RAIN_COLOR * luma(low_sky_color),
        rainStrength
      );
    #else
      vec3 low_sky_color = gl_Fog.color.rgb;
    #endif

    current_fog_color =
      mix(hi_sky_color, low_sky_color, fog_mix_level) * fog_intensity_coeff;

    frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
      mix(fog_density_coeff, .5, rainStrength)
    );
  #endif
#endif

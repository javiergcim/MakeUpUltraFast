#ifndef NETHER
  #ifndef THE_END
    // Fog intensity calculation
    #if defined VOL_LIGHT && defined SHADOW_CASTING
      float fog_density_coeff = FOG_DENSITY;
    #else
      float fog_density_coeff = mix(
        fog_density[current_hour_floor],
        fog_density[current_hour_ceil],
        current_hour_fract
        );
    #endif

    float fog_intensity_coeff = max(
      visible_sky,
      eyeBrightnessSmooth.y * 0.004166666666666667
    );

    frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
      mix(fog_density_coeff, .5, rainStrength)
    );
  #else
    frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0),
      .5
    );
  #endif
#endif

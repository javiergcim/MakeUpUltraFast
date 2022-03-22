#if !defined THE_END && !defined NETHER

 // Fog intensity calculation
  #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
  #else
    float fog_density_coeff = day_blend_float(
      FOG_MIDDLE,
      FOG_DAY,
      FOG_NIGHT
    ) * FOG_ADJUST;
  #endif

  float fog_intensity_coeff = eye_bright_smooth.y * 0.004166666666666667;

  frog_adjust = pow(
    clamp(var_fog_frag_coord / far, 0.0, 1.0) * fog_intensity_coeff,
    mix(fog_density_coeff, 1.0, rainStrength)
  );

#else
  frog_adjust = pow(
      clamp(var_fog_frag_coord / far, 0.0, 1.0),
      .5
    );
#endif

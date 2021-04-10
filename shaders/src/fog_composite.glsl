#ifndef NETHER
  #ifndef THE_END
    float visible_sky = lmcoord.y;
    // visible_sky = 1.0;

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

    vec3 current_fog_color =
      texture(colortex7, texcoord).rgb * fog_intensity_coeff;

    // vec3 current_fog_color = vec3(1.0, 0.0, 0.0);

    float frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
      mix(fog_density_coeff, .5, rainStrength)
    );

    block_color.rgb =
      mix(
        block_color.rgb,
        current_fog_color,
        // frog_adjust
        pow(linear_d, 1.0)
      );

    // block_color.rgb = current_fog_color;
  #else
    current_fog_color = HI_DAY_COLOR;
    frog_adjust = pow(
      clamp(gl_FogFragCoord / far, 0.0, 1.0),
      .5
    );

    block_color.rgb =
      mix(
        block_color.rgb,
        current_fog_color,
        frog_adjust
      );
  #endif
#endif

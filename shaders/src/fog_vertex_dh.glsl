#if !defined THE_END && !defined NETHER
    float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);
    frog_adjust = pow(
        clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fog_intensity_coeff,
        mix(fog_density_coeff * 0.15, 0.5, rainStrength)
    );
#else
    frog_adjust = sqrt(clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0));
#endif
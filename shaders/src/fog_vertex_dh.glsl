#if !defined THE_END && !defined NETHER
    float fogIntensityCoeff = max(eye_bright_smooth.y * 0.004166666666666667, visibleSky);
    frogAdjust = pow(
        clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fogIntensityCoeff,
        mix(fog_density_coeff * 0.15, 0.5, rainStrength)
    );
#else
    frogAdjust = sqrt(clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0));
#endif
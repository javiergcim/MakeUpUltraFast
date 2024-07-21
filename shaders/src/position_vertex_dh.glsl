position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
gl_Position = dhProjection * gbufferModelView * position;

#if AA_TYPE > 1
  gl_Position.xy += taa_offset * gl_Position.w;
#endif

// Fog intensity calculation

float fog_intensity_coeff = eye_bright_smooth.y * 0.004166666666666667;
#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
  float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
#else
  float fog_density_coeff = day_blend_float(
    FOG_SUNSET,
    FOG_DAY,
    FOG_NIGHT
  ) * FOG_ADJUST;
#endif

gl_FogFragCoord = length(position.xyz);

#if !defined THE_END && !defined NETHER
frog_adjust = pow(
  clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fog_intensity_coeff,
  mix(fog_density_coeff * 0.2, 0.5, rainStrength)
);
#else
  frog_adjust = sqrt(clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0));
  // frog_adjust = clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0);
#endif

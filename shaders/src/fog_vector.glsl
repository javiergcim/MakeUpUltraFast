float fog_mix_level;
float fog_intensity_coeff;
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
      eyeBrightnessSmooth.y / 240.0
    );
    current_fog_color = mix(skyColor, gl_Fog.color.rgb, fog_mix_level);
  #endif

  frog_adjust = (gl_FogFragCoord / far) * fog_intensity_coeff;

} else if (isEyeInWater == 1) {  // Underwater (not used, see composite instead)
  fog_density_coeff = 0.5;
  fog_intensity_coeff = 1.0;
  current_fog_color = skyColor;
  frog_adjust = 1.0;
} else {  // Lava (not used, see composite instead)
  fog_density_coeff = 0.5;
  fog_intensity_coeff = 1.0;
  current_fog_color = vec3(1.0, .3, 0.0);
  frog_adjust = 1.0;
}

float fog_mix_level;
float fog_intensity_coeff;
if (isEyeInWater == 0.0) { // In the air
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
    current_fog_color = gl_Fog.color.rgb * .5;
  #else
    fog_intensity_coeff = max(
      visible_sky,
      eyeBrightnessSmooth.y / 240.0
    );
    current_fog_color = mix(skyColor, gl_Fog.color.rgb, fog_mix_level);
  #endif

} else if (isEyeInWater == 1.0) {  // Underwater
  fog_density_coeff = 0.5;
  fog_intensity_coeff = 1.0;
  current_fog_color = waterfog_baselight * real_light;
} else {  // Lava
  fog_density_coeff = 0.5;
  fog_intensity_coeff = 1.0;
  current_fog_color = gl_Fog.color.rgb;
}

frog_adjust = (gl_FogFragCoord / far) * fog_intensity_coeff;

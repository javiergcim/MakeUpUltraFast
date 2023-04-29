#if MC_VERSION >= 11300
  umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .25;
#else
  umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .55;
#endif

dark_cloud_color = day_blend(
  ZENITH_SUNSET_COLOR,
  ZENITH_DAY_COLOR,
  ZENITH_NIGHT_COLOR
);

dark_cloud_color = mix(
  dark_cloud_color,
  ZENITH_SKY_RAIN_COLOR * color_average(dark_cloud_color),
  rainStrength
);

vec3 cloud_color_aux = mix(
day_blend(
  LIGHT_SUNSET_COLOR,
  LIGHT_DAY_COLOR,
  LIGHT_NIGHT_COLOR * vec3(0.5, 0.6, 0.75)
),
ZENITH_SKY_RAIN_COLOR * color_average(dark_cloud_color),
rainStrength
);

cloud_color = mix(
  clamp(mix(vec3(luma(cloud_color_aux)), cloud_color_aux, 0.5) * vec3(1.5), 0.0, 1.4),
  day_blend(
    HORIZON_SUNSET_COLOR,
    HORIZON_DAY_COLOR,
    HORIZON_NIGHT_COLOR
  ),
  0.3
);

cloud_color = mix(cloud_color, HORIZON_SKY_RAIN_COLOR * luma(cloud_color_aux) * 5.0, rainStrength);

dark_cloud_color = mix(dark_cloud_color, cloud_color, 0.22);

dark_cloud_color = mix(
dark_cloud_color,
day_blend(
  cloud_color_aux,
  dark_cloud_color,
  dark_cloud_color
),
0.4
);
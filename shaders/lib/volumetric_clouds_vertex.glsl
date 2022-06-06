umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .25;

dark_cloud_color = day_blend(
  HI_MIDDLE_COLOR,
  HI_DAY_COLOR,
  HI_NIGHT_COLOR
);

dark_cloud_color = mix(
  dark_cloud_color,
  HI_SKY_RAIN_COLOR * color_average(dark_cloud_color),
  rainStrength
);

vec3 cloud_color_aux = mix(
day_blend(
  AMBIENT_MIDDLE_COLOR,
  AMBIENT_DAY_COLOR,
  AMBIENT_NIGHT_COLOR * vec3(0.5, 0.6, 0.75)
),
HI_SKY_RAIN_COLOR * luma(dark_cloud_color),
rainStrength
);

cloud_color = mix(
  clamp(mix(vec3(luma(cloud_color_aux)),cloud_color_aux, 0.6) * vec3(2.0), 0.0, 1.4),
  day_blend(
    LOW_MIDDLE_COLOR,
    LOW_DAY_COLOR,
    LOW_NIGHT_COLOR
  ),
  0.3
);

cloud_color = mix(cloud_color, LOW_SKY_RAIN_COLOR * luma(cloud_color_aux) * 4.5, rainStrength);

dark_cloud_color = mix(dark_cloud_color, cloud_color_aux, 0.25);

dark_cloud_color = mix(
dark_cloud_color,
day_blend(
  cloud_color_aux,
  dark_cloud_color,
  dark_cloud_color
),
0.5
);
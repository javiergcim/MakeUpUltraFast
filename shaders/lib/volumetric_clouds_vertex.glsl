#if MC_VERSION >= 11300
    umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .25;
#else
    umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .55;
#endif

darkCloudColor = dayBlend(
    ZENITH_SUNSET_COLOR,
    ZENITH_DAY_COLOR,
    ZENITH_NIGHT_COLOR
);

darkCloudColor = mix(
    darkCloudColor,
    ZENITH_SKY_RAIN_COLOR * colorAverage(darkCloudColor),
    rainStrength
);

vec3 cloudColor_aux = mix(
    dayBlend(
        LIGHT_SUNSET_COLOR,
        LIGHT_DAY_COLOR,
        LIGHT_NIGHT_COLOR * vec3(0.5, 0.6, 0.75)
    ),
    ZENITH_SKY_RAIN_COLOR * colorAverage(darkCloudColor),
    rainStrength
);

cloudColor = mix(
    clamp(mix(vec3(luma(cloudColor_aux)), cloudColor_aux, 0.5) * vec3(1.5), 0.0, 1.4),
    dayBlend(
        HORIZON_SUNSET_COLOR,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
    ),
    0.3
);

cloudColor = mix(cloudColor, HORIZON_SKY_RAIN_COLOR * luma(cloudColor_aux) * 5.0, rainStrength);

darkCloudColor = mix(darkCloudColor, cloudColor, 0.22);

darkCloudColor = mix(
    darkCloudColor,
    dayBlend(
        cloudColor_aux,
        darkCloudColor,
        darkCloudColor
    ),
    0.4
);
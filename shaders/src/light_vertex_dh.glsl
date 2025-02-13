tint_color = gl_Color;

// Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
#if defined THE_END || defined NETHER
    vec2 illumination = vec2(lmcoord.x, 1.0);
#else
    vec2 illumination = lmcoord;
#endif
illumination.y = (max(illumination.y, 0.065) - 0.065) * 1.06951871657754;
visible_sky = clamp(illumination.y, 0.0, 1.0);

#if defined UNKNOWN_DIM
    visible_sky = (visible_sky * 0.6) + 0.4;
#endif

// Intensidad y color de luz de candelas
#if defined UNKNOWN_DIM
    candle_color =
        CANDLE_BASELIGHT * ((illumination.x * illumination.x) + sixth_pow(illumination.x * 1.205)) * 2.75;
#else
    candle_color =
        CANDLE_BASELIGHT * (pow(illumination.x, 1.5) + sixth_pow(illumination.x * 1.17));
#endif

candle_color = clamp(candle_color, vec3(0.0), vec3(4.0));

// Atenuación por dirección de luz directa ===================================
#if defined THE_END || defined NETHER
    vec3 sun_vec =
        normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = normalize(sunPosition);
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float sun_light_strength;
if (length(normal) != 0.0) {  // Workaround for undefined normals
    normal = normalize(normal);
    sun_light_strength = dot(normal, sun_vec);
} else {
    normal = vec3(0.0, 1.0, 0.0);
    sun_light_strength = 1.0;
}

#if defined THE_END || defined NETHER
    direct_light_strength = sun_light_strength;
#else
    direct_light_strength =
        mix(-sun_light_strength, sun_light_strength, light_mix);
#endif

// Intensidad por dirección
float omni_strength = (direct_light_strength * .125) + 1.0;     

// Calculamos color de luz directa
#ifdef UNKNOWN_DIM
    direct_light_color = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb;
#else
    direct_light_color = day_blend(
        LIGHT_SUNSET_COLOR,
        LIGHT_DAY_COLOR,
        LIGHT_NIGHT_COLOR
    );
#endif

direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);

#if defined THE_END || defined NETHER
    omni_light = LIGHT_DAY_COLOR;
#else
    direct_light_color = mix(
        direct_light_color,
        ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * 0.4,
        rainStrength
    );

    // Minimal light
    vec3 omni_color = mix(hi_sky_color_rgb, direct_light_color * 0.45, OMNI_TINT);
    float omni_color_luma = color_average(omni_color);
    float luma_ratio = AVOID_DARK_LEVEL / omni_color_luma;
    vec3 omni_color_min = omni_color * luma_ratio;
    omni_color = max(omni_color, omni_color_min);
    
    omni_light = mix(omni_color_min, omni_color, visible_sky);

#endif

if (isEyeInWater == 0) {
    direct_light_strength = mix(0.0, direct_light_strength, pow(visible_sky, 10.0));
} else {
    direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
}

if (dhMaterialId == DH_BLOCK_ILLUMINATED) {
    direct_light_strength = 10.0;
} else if (dhMaterialId == DH_BLOCK_LAVA) {
    direct_light_strength = 1.0;
}

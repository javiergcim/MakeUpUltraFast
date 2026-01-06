tintColor = gl_Color;

// Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
#if defined THE_END || defined NETHER
    vec2 illumination = vec2(lmcoord.x, 1.0);
#else
    vec2 illumination = lmcoord;
#endif

illumination.y = max(illumination.y - 0.065, 0.0) * 1.06951871657754;
visibleSky = clamp(illumination.y, 0.0, 1.0);

#if defined UNKNOWN_DIM
    visibleSky = (visibleSky * 0.6) + 0.4;
#endif

// Intensidad y color de luz de candelas
float candle_luma = illumination.x * sqrt(illumination.x);
candleColor = CANDLE_BASELIGHT * (candle_luma + sixthPow(illumination.x * 1.17));
candleColor = clamp(candleColor, vec3(0.0), vec3(4.0));

// Atenuación por dirección de luz directa ===================================
#if defined THE_END || defined NETHER
    vec3 astroVector = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 astroVector = normalize(sunPosition);
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float astroLightStrength;

// Comprobar la longitud al cuadrado (dot product) es mucho más rápido que la longitud (sqrt).
if (dot(normal, normal) > 0.0001) {  // Workaround for undefined normals
    normal = normalize(normal);
    astroLightStrength = dot(normal, astroVector);
} else {
    normal = vec3(0.0, 1.0, 0.0);
    astroLightStrength = 1.0;
}

#if defined THE_END || defined NETHER
    directLightStrength = astroLightStrength;
#else
    directLightStrength = mix(-astroLightStrength, astroLightStrength, dayNightMix);
#endif

// Omni light intensity changes by angle
float omniStrength = ((directLightStrength + 1.0) * 0.25) + 0.75;     

// Calculamos color de luz directa
#ifdef UNKNOWN_DIM
    directLightColor = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb;
#else
    directLightColor = dayBlend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        directLightColor += (endFlashIntensity * endFlashIntensity * 0.1);
    #endif
#endif

directLightStrength = clamp(directLightStrength, 0.0, 1.0);

#if defined THE_END || defined NETHER
    omniLight = LIGHT_DAY_COLOR;
#else
    directLightColor = mix(directLightColor, ZENITH_SKY_RAIN_COLOR * luma(directLightColor) * 0.4, rainStrength);

    // Minimal light
    vec3 omniColor = mix(hi_sky_color_rgb, directLightColor * 0.45, OMNI_TINT);
    float omniColorLuma = colorAverage(omniColor);
    
    // --- OPTIMIZACIÓN #3: Prevenir división por cero ---
    float lumaRatio = AVOID_DARK_LEVEL / max(omniColorLuma, 0.0001);
    
    vec3 omniColorMin = omniColor * lumaRatio;
    omniColor = max(omniColor, omniColorMin);
    
    omniLight = mix(omniColorMin, omniColor, visibleSky) * omniStrength;
#endif

if (isEyeInWater == 0) {
    // Reemplazar pow(x, 10.0) con multiplicaciones ---
    // Esto es órdenes de magnitud más rápido. x^10 = (x^2)^2 * x^2
    float visSky2 = visibleSky * visibleSky;     // x^2
    float visSky4 = visSky2 * visSky2;       // x^4
    float visSky8 = visSky4 * visSky4;       // x^8
    float vis_sky_10 = visSky8 * visSky2;      // x^10
    directLightStrength = mix(0.0, directLightStrength, vis_sky_10);
} else {
    directLightStrength = mix(0.0, directLightStrength, visibleSky);
}

if (dhMaterialId == DH_BLOCK_ILLUMINATED) {
    directLightStrength = 10.0;
} else if (dhMaterialId == DH_BLOCK_LAVA) {
    directLightStrength = 1.0;
}

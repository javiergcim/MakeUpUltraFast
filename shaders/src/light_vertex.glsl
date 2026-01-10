tintColor = gl_Color;

// Native light (lmcoord.x: candel, lmcoord.y: sky) ----
vec2 illumination = lmcoord;
illumination.y = max(illumination.y - 0.065, 0.0) * 1.06951871657754;
visibleSky = clamp(illumination.y, 0.0, 1.0);

// Underwater light adjust
if (isEyeInWater == 1) {
    visibleSky = (visibleSky * .95) + .05;
}

#if defined UNKNOWN_DIM
    visibleSky = (visibleSky * 0.99) + 0.01;
#endif

// Candels color and intensity
candleColor = CANDLE_BASELIGHT * (illumination.x * sqrt(illumination.x) + sixthPow(illumination.x * 1.17));

#ifdef DYN_HAND_LIGHT
    if (heldItemId == 11001 || heldItemId2 == 11001 || heldItemId == 11002 || heldItemId2 == 11002) {
        float distanceOffset = (heldItemId == 11001 || heldItemId2 == 11001) ? 0.0 : 0.5;
        float handDistance = (1.0 - clamp((gl_FogFragCoord * 0.06666666666666667) + distanceOffset, 0.0, 1.0));
        vec3 handLight = CANDLE_BASELIGHT * (handDistance * sqrt(handDistance) + sixthPow(handDistance * 1.17));
        candleColor = max(candleColor, handLight);
    }
#endif

candleColor = clamp(candleColor, vec3(0.0), vec3(4.0));

// Atenuation by light angle ===================================
#if defined THE_END || defined NETHER
    vec3 astroVector = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 astroVector = normalize(sunPosition);
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float astroLightStrength;
if (dot(normal, normal) > 0.0001) { // Workaround for undefined normals
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
// float omniStrength = (directLightStrength * .125) + 1.0;
// float omniStrength = (directLightStrength) + 1.0;

// Direct light color
#ifdef UNKNOWN_DIM
    directLightColor = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb;
#else
    directLightColor = dayBlend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        directLightColor += (endFlashIntensity * endFlashIntensity * 0.1);
    #endif
#endif

// Omni light intensity changes by angle
float omniStrength = ((directLightStrength + 1.0) * 0.25) + 0.75;

// Direct light strenght --
#ifdef FOLIAGE_V  // This shader has foliage
    // --- CORRECCIÓN: La variable se declara y calcula aquí, fuera del if/else ---
    // Esto asegura que 'farDirectLightStrength' esté siempre disponible después de este bloque.
    float farDirectLightStrength = clamp(directLightStrength, 0.0, 1.0);
    if (mc_Entity.x != ENTITY_LEAVES) {
        farDirectLightStrength = farDirectLightStrength * 0.75 + 0.25;
    }
    
    // Ahora, la lógica del if/else solo modifica 'directLightStrength' y 'omniStrength'.
    if (isFoliage > .2) {  // It's foliage, light is atenuated by angle
        #ifdef SHADOW_CASTING
            directLightStrength = sqrt(abs(directLightStrength));
        #else
            directLightStrength = (clamp(directLightStrength, 0.0, 1.0) * 0.5 + 0.5) * 0.75;
        #endif
        omniStrength = 1.0;
    } else {
        directLightStrength = clamp(directLightStrength, 0.0, 1.0);
    }
#else
    directLightStrength = clamp(directLightStrength, 0.0, 1.0);
#endif

// Omni light color
#if defined THE_END || defined NETHER
    omniLight = LIGHT_DAY_COLOR * omniStrength;
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

// Avoid flat illumination in caves for entities
#ifdef CAVEENTITY_V
    float candleCaveStrength = (directLightStrength * .5) + .5;
    candleCaveStrength = mix(candleCaveStrength, 1.0, visibleSky);
    candleColor *= candleCaveStrength;
#endif

#if !defined THE_END && !defined NETHER
    #ifndef SHADOW_CASTING
        // Fake shadows
        if (isEyeInWater == 0) {
            // Reemplazar pow(x, 10.0) con multiplicaciones ---
            float visSky2 = visibleSky * visibleSky;
            float visSky4 = visSky2 * visSky2;
            float visSky8 = visSky4 * visSky4;
            directLightStrength = mix(0.0, directLightStrength, visSky8 * visSky2);
        } else {
            directLightStrength = mix(0.0, directLightStrength, visibleSky);
        }
    #else
        directLightStrength = mix(0.0, directLightStrength, visibleSky);
    #endif
#endif

#ifdef EMMISIVE_V
    if (isFakeEmmisor > 0.5) {
        omniLight = vec3(0.45);
    }
#endif
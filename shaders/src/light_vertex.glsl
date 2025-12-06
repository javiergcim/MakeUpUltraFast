tint_color = gl_Color;

// Native light (lmcoord.x: candel, lmcoord.y: sky) ----
vec2 illumination = lmcoord;
illumination.y = max(illumination.y - 0.065, 0.0) * 1.06951871657754;
visible_sky = clamp(illumination.y, 0.0, 1.0);

// Underwater light adjust
if (isEyeInWater == 1) {
    visible_sky = (visible_sky * .95) + .05;
}

#if defined UNKNOWN_DIM
    visible_sky = (visible_sky * 0.99) + 0.01;
#endif

// Candels color and intensity
// Reemplazar pow(x, 1.5) por x * sqrt(x) ---
candle_color = CANDLE_BASELIGHT * (illumination.x * sqrt(illumination.x) + sixth_pow(illumination.x * 1.17));

#ifdef DYN_HAND_LIGHT
    if (heldItemId == 11001 || heldItemId2 == 11001 || heldItemId == 11002 || heldItemId2 == 11002) {
        float dist_offset = (heldItemId == 11001 || heldItemId2 == 11001) ? 0.0 : 0.5;
        float hand_dist = (1.0 - clamp((gl_FogFragCoord * 0.06666666666666667) + dist_offset, 0.0, 1.0));
        // --- OPTIMIZACIÓN #1 (de nuevo): Reemplazar pow(x, 1.5) ---
        vec3 hand_light = CANDLE_BASELIGHT * (hand_dist * sqrt(hand_dist) + sixth_pow(hand_dist * 1.17));
        candle_color = max(candle_color, hand_light);
    }
#endif

candle_color = clamp(candle_color, vec3(0.0), vec3(4.0));

// Atenuation by light angle ===================================
#if defined THE_END || defined NETHER
    vec3 sun_vec = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = normalize(sunPosition);
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float sun_light_strength;
// Evitar length() en el condicional ---
if (dot(normal, normal) > 0.0001) { // Workaround for undefined normals
    normal = normalize(normal);
    sun_light_strength = dot(normal, sun_vec);
} else {
    normal = vec3(0.0, 1.0, 0.0);
    sun_light_strength = 1.0;
}

#if defined THE_END || defined NETHER
    direct_light_strength = sun_light_strength;
#else
    direct_light_strength = mix(-sun_light_strength, sun_light_strength, light_mix);
#endif

// Omni light intensity changes by angle
float omni_strength = (direct_light_strength * .125) + 1.0;

// Direct light color
#ifdef UNKNOWN_DIM
    direct_light_color = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb;
#else
    direct_light_color = day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        direct_light_color += (endFlashIntensity * endFlashIntensity * 0.1);
    #endif
#endif

// Direct light strenght --
#ifdef FOLIAGE_V  // This shader has foliage
    // --- CORRECCIÓN: La variable se declara y calcula aquí, fuera del if/else ---
    // Esto asegura que 'far_direct_light_strength' esté siempre disponible después de este bloque.
    float far_direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
    if (mc_Entity.x != ENTITY_LEAVES) {
        far_direct_light_strength = far_direct_light_strength * 0.75 + 0.25;
    }
    
    // Ahora, la lógica del if/else solo modifica 'direct_light_strength' y 'omni_strength'.
    if (is_foliage > .2) {  // It's foliage, light is atenuated by angle
        #ifdef SHADOW_CASTING
            direct_light_strength = sqrt(abs(direct_light_strength));
        #else
            direct_light_strength = (clamp(direct_light_strength, 0.0, 1.0) * 0.5 + 0.5) * 0.75;
        #endif
        omni_strength = 1.0;
    } else {
        direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
    }
#else
    direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
#endif

// Omni light color
#if defined THE_END || defined NETHER
    omni_light = LIGHT_DAY_COLOR;
#else
    direct_light_color = mix(direct_light_color, ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * 0.4, rainStrength);

    // Minimal light
    vec3 omni_color = mix(hi_sky_color_rgb, direct_light_color * 0.45, OMNI_TINT);
    float omni_color_luma = color_average(omni_color);
    // --- OPTIMIZACIÓN #3: Prevenir división por cero ---
    float luma_ratio = AVOID_DARK_LEVEL / max(omni_color_luma, 0.0001);
    vec3 omni_color_min = omni_color * luma_ratio;
    omni_color = max(omni_color, omni_color_min);
    
    omni_light = mix(omni_color_min, omni_color, visible_sky);
#endif

// Avoid flat illumination in caves for entities
#ifdef CAVEENTITY_V
    float candle_cave_strength = (direct_light_strength * .5) + .5;
    candle_cave_strength = mix(candle_cave_strength, 1.0, visible_sky);
    candle_color *= candle_cave_strength;
#endif

#if !defined THE_END && !defined NETHER
    #ifndef SHADOW_CASTING
        // Fake shadows
        if (isEyeInWater == 0) {
            // Reemplazar pow(x, 10.0) con multiplicaciones ---
            float vis_sky_2 = visible_sky * visible_sky;
            float vis_sky_4 = vis_sky_2 * vis_sky_2;
            float vis_sky_8 = vis_sky_4 * vis_sky_4;
            direct_light_strength = mix(0.0, direct_light_strength, vis_sky_8 * vis_sky_2);
        } else {
            direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
        }
    #else
        direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
    #endif
#endif

#ifdef EMMISIVE_V
    if (is_fake_emmisor > 0.5) {
        omni_light = vec3(0.45);
    }
#endif
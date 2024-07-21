tint_color = gl_Color;

// Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
vec2 illumination = lmcoord;
illumination.y = (max(illumination.y, 0.065) - 0.065) * 1.06951871657754;

// Visibilidad del cielo
#ifdef WATER_F
  visible_sky = illumination.y;
#else
  float visible_sky = illumination.y;
#endif
visible_sky = clamp(visible_sky, 0.0, 1.0);

// Ajuste de intensidad luminosa bajo el agua
if (isEyeInWater == 1) {
  visible_sky = (visible_sky * .95) + .05;
}

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

#ifdef DYN_HAND_LIGHT
  float dist_factor;
  float hand_dist;
  vec3 hand_light;

  if (heldItemId == 11001 || heldItemId2 == 11001) {  // Normal light
    hand_dist = (1.0 - clamp((gl_FogFragCoord * 0.06666666666666667), 0.0, 1.0));
    hand_light = CANDLE_BASELIGHT * (pow(hand_dist, 1.5) + sixth_pow(hand_dist * 1.17));
    candle_color = max(candle_color, hand_light);
  } else if (heldItemId == 11002 || heldItemId2 == 11002) {
    hand_dist = (1.0 - clamp((gl_FogFragCoord * 0.06666666666666667) + 0.5, 0.0, 1.0));
    hand_light = CANDLE_BASELIGHT * (pow(hand_dist, 1.5) + sixth_pow(hand_dist * 1.17));
    candle_color = max(candle_color, hand_light);
  }
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

#ifdef FOLIAGE_V  // Puede haber plantas en este shader
  float original_direct_light_strength = clamp(direct_light_strength, 0.0, 1.0) * 0.9 + 0.1;
  if (is_foliage > .2) {  // Es "planta" y se atenúa luz por dirección
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

#if defined THE_END || defined NETHER
  omni_light = LIGHT_DAY_COLOR;
#else
  // Calculamos color de luz ambiental

  vec3 hi_sky_color = day_blend(
    ZENITH_SUNSET_COLOR,
    ZENITH_DAY_COLOR,
    ZENITH_NIGHT_COLOR
    );

  vec3 sky_rain_color = ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color);

  #ifdef SIMPLE_AUTOEXP
    direct_light_color = mix(
      direct_light_color,
      ZENITH_SKY_RAIN_COLOR * luma(direct_light_color),
      rainStrength
    );
  #else
    direct_light_color = mix(
      direct_light_color,
      ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * 0.4,
      rainStrength
    );
  #endif

  hi_sky_color = mix(
    hi_sky_color,
    sky_rain_color,
    rainStrength
  );

  float sky_day_pseudoluma = color_average(ZENITH_DAY_COLOR);
  float current_sky_pseudoluma = color_average(hi_sky_color);

  float luma_ratio = sky_day_pseudoluma / current_sky_pseudoluma;

  // Luz mínima
  float omni_minimal = AVOID_DARK_LEVEL * luma_ratio;
  float visible_avoid_dark = (pow(visible_sky, 1.5) * (1.0 - omni_minimal)) + omni_minimal;

  omni_light = visible_avoid_dark * omni_strength *
    mix(hi_sky_color, direct_light_color * 0.75, OMNI_TINT);

#endif

#ifdef CAVEENTITY_V
  // Avoid flat illumination in caves for entities
  float candle_cave_strength = (direct_light_strength * .5) + .5;
  candle_cave_strength =
    mix(candle_cave_strength, 1.0, visible_sky);
  candle_color *= candle_cave_strength;
#endif

#if !defined THE_END && !defined NETHER
  #ifndef SHADOW_CASTING
    // Fake shadows
    if (isEyeInWater == 0) {
      direct_light_strength = mix(0.0, direct_light_strength, pow(visible_sky, 10.0));
    } else {
      direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
    }
  #else
    direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
  #endif
#endif

#ifdef EMMISIVE_V
  if (is_fake_emmisor > 0.5) {
    direct_light_strength = 10.0;
  }
#endif
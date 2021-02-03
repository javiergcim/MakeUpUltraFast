#ifdef NETHER  // The Nether ===================================================
  tint_color = gl_Color;
  #ifdef EMMISIVE_V
  if (emissive > 0.5 || magma > 0.5) {  // Es bloque es emisivo
    tint_color.rgb *= 2.5;
  }
  #endif

  vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
  vec3 lava_vec = normalize(gbufferModelView * vec4(0.0, -1.0, 0.0, 0.0)).xyz;

  float direct_light_strenght = dot(normal, lava_vec);
  direct_light_strenght = clamp(direct_light_strenght, 0.0, 1.0);

  // Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
  vec2 illumination = lmcoord;

  vec3 omni_color = NETHER_OMNI;
  vec3 direct_light_color = NETHER_DIRECT * direct_light_strenght;
  vec3 candle_color = CANDLE_BASELIGHT * cube_pow(illumination.x);

  real_light = omni_color + direct_light_color + candle_color;

#else  // Overworld and The End ================================================

  tint_color = gl_Color;

  #ifdef EMMISIVE_V
  if (emissive > 0.5 || magma > 0.5) {  // Es bloque es emisivo
    tint_color.rgb *= 2.0;
  }
  #endif

  // Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
  vec2 illumination = lmcoord;

  // Intensidad según mirada al cielo ==========================================
  illumination.y = max(illumination.y, 0.095);  // Remueve artefacto

  // Visibilidad del cielo
  float visible_sky = illumination.y * 1.105 - .10495;

  // Ajuste de intensidad luminosa bajo el agua
  if (isEyeInWater == 1) {
    visible_sky = (visible_sky * .95) + .05;
  }

  // Intensidad y color de luz de candelas
  candle_color = CANDLE_BASELIGHT * cube_pow(illumination.x);

  // Atenuación por dirección de luz directa ===================================
  #ifdef THE_END
    vec3 sun_vec =
      normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
  #else
    vec3 sun_vec = normalize(sunPosition);
  #endif

  vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
  float sun_light_strenght = dot(normal, sun_vec);

  #ifdef THE_END
    direct_light_strenght = sun_light_strenght;
  #else
    direct_light_strenght =
      mix(-sun_light_strenght, sun_light_strenght, light_mix);
  #endif

  #if SHADOW_CASTING == 1
    shadow_mask = direct_light_strenght - 0.00005;  // -.00005 Flashing bug
  #endif

  // Intensidad por dirección
  float omni_strenght = (direct_light_strenght * .125) + .75;
  direct_light_strenght = clamp(direct_light_strenght, 0.0, 1.0);

  // Calculamos color de luz directa
  direct_light_color = day_color_mixer(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR,
    day_moment
    );

  #ifdef FOLIAGE_V  // Puede haber plantas en este shader
    if (is_foliage > .2) {  // Es "planta" y se atenúa luz por dirección
      #ifndef THE_END
        float foliage_attenuation_coef = abs((light_mix - .5) * 2.0);
      #else
        float foliage_attenuation_coef = 1.0;
      #endif

      #if SHADOW_CASTING == 1
        direct_light_strenght =
          mix(direct_light_strenght, 1.0, .7 * foliage_attenuation_coef);
      #else
        direct_light_strenght =
        mix(direct_light_strenght, 1.0, .2 * foliage_attenuation_coef) * .55;
        omni_strenght = 1.0;
      #endif
    }
  #endif

  #ifdef THE_END
    omni_light = AMBIENT_DAY_COLOR;
  #else
    // Calculamos color de luz ambiental

    vec3 hi_sky_color = day_color_mixer(
      HI_MIDDLE_COLOR,
      HI_DAY_COLOR,
      HI_NIGHT_COLOR,
      day_moment
      );

    direct_light_color = mix(
      direct_light_color,
      HI_SKY_RAIN_COLOR * luma(hi_sky_color),
      rainStrength
    );

    hi_sky_color = mix(
      hi_sky_color,
      HI_SKY_RAIN_COLOR * luma(hi_sky_color),
      rainStrength
    );

    #if AVOID_DARK == 1
      omni_light = max(visible_sky * visible_sky, .028) * omni_strenght *
        mix(hi_sky_color, direct_light_color, OMNI_TINT);
    #else
      omni_light = visible_sky * visible_sky * omni_strenght *
        mix(hi_sky_color, direct_light_color, OMNI_TINT);
    #endif

  #endif

  #ifdef CAVEENTITY_V
    // Avoid flat illumination in caves for entities
    float candle_cave_strenght = (direct_light_strenght * .5) + .5;
    candle_cave_strenght =
      mix(candle_cave_strenght, 1.0, visible_sky);
    candle_color *= candle_cave_strenght;
  #endif

  #ifndef THE_END
    #if SHADOW_CASTING == 0
      // Fake shadows
      direct_light_strenght = mix(0.0, direct_light_strenght, pow(visible_sky, 10.0)) * 1.5;
    #else
      direct_light_strenght = mix(0.0, direct_light_strenght, visible_sky);
    #endif
  #endif

#endif

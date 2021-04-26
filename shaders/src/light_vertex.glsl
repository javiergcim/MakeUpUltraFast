#ifdef NETHER  // The Nether ===================================================
  tint_color = gl_Color;

  #ifdef EMMISIVE_V
  if (emissive > 0.5) {  // Es bloque es emisivo
    tint_color.rgb *= 4.0;
  } else if (magma > 0.5) {
    tint_color.rgb *= 2.0;
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

  // Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
  vec2 illumination = lmcoord;

  // Intensidad según mirada al cielo ==========================================
  illumination.y = max(illumination.y, 0.095);  // Remueve artefacto

  // Visibilidad del cielo
  // float visible_sky = illumination.y * 1.105 - .10495;
  #ifdef WATER_F
    visible_sky = illumination.y * 1.0323886639676114;
  #else
    float visible_sky = illumination.y * 1.0323886639676114;
  #endif

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

  // Intensidad por dirección
  float omni_strenght = (direct_light_strenght * .125) + 1.0;

  // Calculamos color de luz directa
  direct_light_color = day_blend(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR
    );

  #ifdef FOLIAGE_V  // Puede haber plantas en este shader
    if (is_foliage > .2) {  // Es "planta" y se atenúa luz por dirección
      #ifdef SHADOW_CASTING
        direct_light_strenght = sqrt(abs(direct_light_strenght));
      #else
        #ifndef THE_END
          float foliage_attenuation_coef = abs((light_mix - .5) * 2.0);
        #else
          float foliage_attenuation_coef = 1.0;
        #endif

        direct_light_strenght =
        mix(clamp(direct_light_strenght, 0.0, 1.0), 1.0, .25 * foliage_attenuation_coef) * .75;
      #endif

      omni_strenght = 1.0;
    }
  #endif

  direct_light_strenght = clamp(direct_light_strenght, 0.0, 1.0);

  #ifdef THE_END
    omni_light = AMBIENT_DAY_COLOR;
  #else
    // Calculamos color de luz ambiental

    vec3 hi_sky_color = day_blend(
      HI_MIDDLE_COLOR,
      HI_DAY_COLOR,
      HI_NIGHT_COLOR
      );

    vec3 sky_color = HI_SKY_RAIN_COLOR * luma(hi_sky_color);

    direct_light_color = mix(
      direct_light_color,
      HI_SKY_RAIN_COLOR * luma(direct_light_color),
      rainStrength
    );

    hi_sky_color = mix(
      hi_sky_color,
      sky_color,
      rainStrength
    );

    #if AVOID_DARK == 1
      omni_light = max(visible_sky * visible_sky, .055) * omni_strenght *
        mix(hi_sky_color, direct_light_color * 0.75, OMNI_TINT);
    #else
      omni_light = visible_sky * visible_sky * omni_strenght *
        mix(hi_sky_color, direct_light_color * 0.75, OMNI_TINT);
    #endif

  #endif

  #ifdef CAVEENTITY_V
    // Avoid flat illumination in caves for entities
    float candle_cave_strenght = (direct_light_strenght * .5) + .5;
    candle_cave_strenght =
      mix(candle_cave_strenght, 1.0, visible_sky);
    candle_color *= candle_cave_strenght;
  #endif

  #ifdef EMMISIVE_V
    #ifdef THE_END
    if (emissive > 0.5) {  // Es bloque es emisivo
      tint_color.rgb *= 4.75;
      direct_light_strenght *= 0.2;
      omni_light *= 0.5;
      } else if (magma > 0.5) {
        tint_color.rgb *= 2.0;
        direct_light_strenght *= 0.2;
        omni_light *= 0.5;
      }
    #else
      if (emissive > 0.5) {  // Es bloque es emisivo
        tint_color.rgb *= 4.75;
        direct_light_strenght *= 0.2;
        omni_light *= 0.5;
        } else if (magma > 0.5) {
          tint_color.rgb *= 2.8;
          direct_light_strenght *= 0.2;
          omni_light *= 0.5;
        }
    #endif


  #endif

  #ifndef THE_END
    #ifndef SHADOW_CASTING
      // Fake shadows
      direct_light_strenght = mix(0.0, direct_light_strenght, pow(visible_sky, 10.0));
    #else
      direct_light_strenght = mix(0.0, direct_light_strenght, visible_sky);
    #endif
  #endif

#endif

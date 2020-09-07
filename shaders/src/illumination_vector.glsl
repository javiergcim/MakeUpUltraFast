// Custom light (lmcoord.x: candle, lmcoord.y: sky direct) ----
vec2 illumination = lmcoord;

illumination.y = max(illumination.y, 0.09);  // lmcoord.y artifact remover
illumination.y = (illumination.y * 1.085) - .085;  // Avoid dimmed light

// Ajuste de intensidad luminosa bajo el agua
if (isEyeInWater == 1.0) {
  illumination.y = (illumination.y * .95) + .05;
}

illumination_y = illumination.y;

// Tomamos el color de luz directa con base a la hora
vec3 sky_currentlight =
  mix(
    ambient_baselight[current_hour_floor],
    ambient_baselight[current_hour_ceil],
    current_hour_fract
  ) * ambient_multiplier;

candle_color =
  candle_baselight * illumination.x * illumination.x * illumination.x;

// Ajuste de luz directa en tormenta
pseudo_light = sky_currentlight * (1.0 - (rainStrength * .3));

// Color de luz omnidireccional
vec3 omni_light = skyColor * mix(
  omni_force[current_hour_floor],
  omni_force[current_hour_ceil],
  current_hour_fract
);

// Indica que tan oculto estás del cielo
float visible_sky = clamp(lmcoord.y * 1.1 - .1, 0.0, 1.0);
tint_color = gl_Color;

vec3 sun_vec = normalize(sunPosition);

// ¿Es bloque no emisivo?
#ifdef EMMISIVE_V
if (emissive < 0.5 && magma < 0.5) {  // Es bloque no emisivo
#endif

  float direct_light_strenght = 1.0;
  omni_light *= illumination_y;

  #ifndef ENTITY_V
  if (visible_sky > 0.0) {
  #endif
    // Fuerza de luz según dirección
    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    float sun_light_strenght = dot(normal, sun_vec);
    direct_light_strenght =
      mix(-sun_light_strenght, sun_light_strenght, light_mix);

    // Avoid extreme darkness
    direct_light_strenght = (direct_light_strenght * .45) + .55;

    #ifdef CAVEENTITY_V
      // Para evitar iluminación plana en cuevas
      float candle_cave_strenght = (direct_light_strenght * .5) + .5;
      candle_cave_strenght =
        mix(candle_cave_strenght, 1.0, visible_sky);
      candle_color *= candle_cave_strenght;
    #endif

    direct_light_strenght = mix(1.0, direct_light_strenght, visible_sky);

  #ifndef ENTITY_V
  }
  #endif

  #ifdef FOLIAGE_V

    if (
      mc_Entity.x == ENTITY_SMALLGRASS ||
      mc_Entity.x == ENTITY_LOWERGRASS ||
      mc_Entity.x == ENTITY_VINES ||
      mc_Entity.x == ENTITY_UPPERGRASS ||
      mc_Entity.x == ENTITY_SMALLENTS ||
      mc_Entity.x == ENTITY_LEAVES
    ) {  // Es "planta"
      direct_light_strenght = mix(direct_light_strenght, 1.0, .2);
    }

  #endif

  direct_light_strenght = clamp((direct_light_strenght + illumination.y - 1.0), 0.0, 1.0);
  #ifdef NETHER
    real_light = sky_currentlight + candle_color;
  #else
    real_light = (pseudo_light * direct_light_strenght) + candle_color + omni_light;
  #endif
  real_light = mix(real_light, vec3(1.0), nightVision * .125);

#ifdef EMMISIVE_V
}
#endif

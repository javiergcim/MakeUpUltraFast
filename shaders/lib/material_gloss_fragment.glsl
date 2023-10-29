#if defined THE_END
  float material_gloss(vec3 reflected_vector, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal) {
    vec3 astro_pos = (gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
    float astro_vector =
      max(dot(normalize(reflected_vector), normalize(astro_pos)), 0.0) *
      step(0.0001, dot(astro_pos, flat_normal));

    return clamp(
        mix(0.0, 1.0, pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), gloss_power)),
        0.0,
        1.0
      );
  }

#else

  float material_gloss(vec3 reflected_vector, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal) {
    vec3 astro_pos = mix(-sunPosition, sunPosition, light_mix);
    float astro_vector =
      max(dot(normalize(reflected_vector), normalize(astro_pos)), 0.0) *
      step(0.0001, dot(astro_pos, flat_normal));

    return clamp(
        mix(0.0, 1.0, pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), gloss_power)) *
        clamp(lmcoord_alt.y, 0.0, 1.0) *
        (1.0 - rainStrength),
        0.0,
        1.0
      ) * abs(mix(1.0, -1.0, light_mix));
  }

#endif
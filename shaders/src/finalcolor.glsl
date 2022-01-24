#if defined THE_END
  if (isEyeInWater == 0) {  // In the air
    block_color.rgb =
      mix(
        block_color.rgb,
        HI_DAY_COLOR,
        frog_adjust
      );
  }
#elif defined NETHER
  if (isEyeInWater == 0) {  // In the air
    block_color.rgb =
      mix(
        block_color.rgb,
        mix(fogColor * 0.1, vec3(1.0), 0.04),
        frog_adjust
      );
  }
#else
  #if defined GBUFFER_ENTITIES
    if (isEyeInWater == 0 && entityId != 10101) {  // In the air

      vec3 hi_sky_color = day_blend(
        HI_MIDDLE_COLOR,
        HI_DAY_COLOR,
        HI_NIGHT_COLOR
        );

      hi_sky_color = mix(
        hi_sky_color,
        HI_SKY_RAIN_COLOR * luma(hi_sky_color),
        rainStrength
      );

      vec3 low_sky_color = day_blend(
        LOW_MIDDLE_COLOR,
        LOW_DAY_COLOR,
        LOW_NIGHT_COLOR
        );

      low_sky_color = mix(
        low_sky_color,
        LOW_SKY_RAIN_COLOR * luma(low_sky_color),
        rainStrength
      );

      vec4 fragpos = gbufferProjectionInverse *
      (
        vec4(
          gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
          gl_FragCoord.z,
          1.0
        ) * 2.0 - 1.0
      );
      vec3 nfragpos = normalize(fragpos.xyz);
      float n_u = clamp(dot(nfragpos, up_vec), 0.0, 1.0);
      vec3 background_color = mix(
        low_sky_color,
        hi_sky_color,
        sqrt(n_u)
      );










    block_color.rgb =
      mix(
        block_color.rgb,
        background_color,
        frog_adjust
      );
    }
  #else
    if (isEyeInWater == 0) {  // In the air

      vec3 hi_sky_color = day_blend(
        HI_MIDDLE_COLOR,
        HI_DAY_COLOR,
        HI_NIGHT_COLOR
        );

      hi_sky_color = mix(
        hi_sky_color,
        HI_SKY_RAIN_COLOR * luma(hi_sky_color),
        rainStrength
      );

      vec3 low_sky_color = day_blend(
        LOW_MIDDLE_COLOR,
        LOW_DAY_COLOR,
        LOW_NIGHT_COLOR
        );

      low_sky_color = mix(
        low_sky_color,
        LOW_SKY_RAIN_COLOR * luma(low_sky_color),
        rainStrength
      );

      vec4 fragpos = gbufferProjectionInverse *
      (
        vec4(
          gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
          gl_FragCoord.z,
          1.0
        ) * 2.0 - 1.0
      );
      vec3 nfragpos = normalize(fragpos.xyz);
      float n_u = clamp(dot(nfragpos, up_vec), 0.0, 1.0);
      vec3 background_color = mix(
        low_sky_color,
        hi_sky_color,
        sqrt(n_u)
      );







      block_color.rgb =
        mix(
          block_color.rgb,
          background_color,
          frog_adjust
        );
    }
  #endif
#endif

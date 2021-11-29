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
  #if defined GBUFFER_ENTITIES_GLOWING
    if (isEyeInWater == 0 && entityId != 10101) {  // In the air
    block_color.rgb =
      mix(
        block_color.rgb,
        texture(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb,
        frog_adjust
      );
    }
  #else
    if (isEyeInWater == 0) {  // In the air
      block_color.rgb =
        mix(
          block_color.rgb,
          texture(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb,
          frog_adjust
        );
    }
  #endif
#endif

#if defined THE_END
  if (isEyeInWater == 0) {  // In the air
    block_color.rgb =
      mix(
        block_color.rgb,
        ZENITH_DAY_COLOR,
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
  #if MC_VERSION >= 11900
    vec3 fog_texture;
    if (darknessFactor > .01) {
      fog_texture = vec3(0.0);
    } else {
      fog_texture = sky_base;
    }
  #else
    vec3 fog_texture = sky_base;
  #endif
  #if defined GBUFFER_ENTITIES
    if (isEyeInWater == 0 && entityId != 10101) {  // In the air
    block_color.rgb =
      mix(
        block_color.rgb,
        fog_texture,
        frog_adjust
      );
    }
  #else
    if (isEyeInWater == 0) {  // In the air
      block_color.rgb =
        mix(
          block_color.rgb,
          fog_texture,
          frog_adjust
        );
    }
  #endif
#endif

#if MC_VERSION >= 11900
  if (blindness > .01 || darknessFactor > .01) {
    block_color.rgb =
      mix(block_color.rgb, vec3(0.0), max(blindness, darknessLightFactor) * gl_FogFragCoord * 0.24);
  }
#else
  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * gl_FogFragCoord * 0.24);
  }
#endif
  #ifndef NETHER
    if (isEyeInWater == 0) {  // In the air
      block_color.rgb =
        mix(
          block_color.rgb,
          current_fog_color,
          frog_adjust
        );
    }
  #endif

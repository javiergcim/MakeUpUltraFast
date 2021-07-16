  #ifndef NETHER
    if (isEyeInWater == 0) {  // In the air
      block_color.rgb =
        mix(
          block_color.rgb,
          texture2D(colortex7, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb,
          frog_adjust
        );
    }
  #endif

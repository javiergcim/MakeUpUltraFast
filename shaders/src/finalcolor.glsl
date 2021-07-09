  #ifndef NETHER
    if (isEyeInWater == 0) {  // In the air
      block_color.rgb =
        mix(
          block_color.rgb,
          // current_fog_color,
          texture2D(colortex7, gl_FragCoord.xy / vec2(1920.0, 1080.0)).rgb,
          frog_adjust
        );
      // block_color.rgb = vec3(gl_FragCoord.xy / vec2(1920.0, 1080.0), 0.0);
    }
  #endif

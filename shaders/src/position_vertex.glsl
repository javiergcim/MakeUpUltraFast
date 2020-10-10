// Waving plants calculation
#ifdef FOLIAGE_V
  #if WAVING == 1
    vec3 position =
      mat3(gbufferModelViewInverse) *
      (gl_ModelViewMatrix * gl_Vertex).xyz +
      gbufferModelViewInverse[3].xyz;
    // vec3 position = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;

    vec3 vworldpos = position.xyz + cameraPosition;

    if (mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      float amt = float(texcoord.y < mc_midTexCoord.y);

      if (mc_Entity.x == ENTITY_UPPERGRASS) {
        amt += 1.0;
      } else if (mc_Entity.x == ENTITY_LEAVES) {
        amt = .5;
      }

      position.xyz += wave_move(vworldpos.xyz,
      0.0041,
      0.0070,
      0.0044,
      0.0038,
      0.0240,
      0.0000,
      vec3(0.8, 0.0, 0.8),
      vec3(0.4, 0.0, 0.4)) * amt * lmcoord.y * (1.0 + (wetness * 3.0));
    }

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);

  #else  // Normal position
    #ifndef NO_SHADOWS
      #if SHADOW_CASTING == 1
        vec3 position =
          mat3(gbufferModelViewInverse) *
          (gl_ModelViewMatrix * gl_Vertex).xyz +
          gbufferModelViewInverse[3].xyz;
      #endif
    #endif

    gl_Position = ftransform();

  #endif

#else
  #ifndef NO_SHADOWS
    #if SHADOW_CASTING == 1
      vec3 position =
        mat3(gbufferModelViewInverse) *
        (gl_ModelViewMatrix * gl_Vertex).xyz +
        gbufferModelViewInverse[3].xyz;
      // vec3 position = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;
    #endif
  #endif

  gl_Position = ftransform();

#endif

#if AA_TYPE == 2
  gl_Position.xy += offsets[frame_mod] * gl_Position.w * texelSize;
#endif

gl_FogFragCoord = length(gl_Position.xyz);

// Waving plants calculation
#ifdef FOLIAGE_V
  #if WAVING == 1
    vec3 position =
      mat3(gbufferModelViewInverse) *
      (gl_ModelViewMatrix * gl_Vertex).xyz +
      gbufferModelViewInverse[3].xyz;

    vec3 worldpos = position.xyz + cameraPosition;

    if (mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      float weight = float(texcoord.y < mc_midTexCoord.y);

      if (mc_Entity.x == ENTITY_UPPERGRASS) {
        weight += 1.0;
      } else if (mc_Entity.x == ENTITY_LEAVES) {
        weight = .3;
      }

      weight *= lmcoord.y;  // Evitamos movimiento en cuevas

      position.xyz +=
        wave_move(worldpos.xz) * weight * (0.022 + (rainStrength * .044));
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
    #endif
  #endif

  gl_Position = ftransform();

#endif

#if AA_TYPE == 2
  gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
#endif

gl_FogFragCoord = length(gl_Position.xyz);

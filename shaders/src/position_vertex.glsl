// Waving plants calculation
#ifdef FOLIAGE_V
  #if WAVING == 1
    vec3 position =
      mat3(gbufferModelViewInverse) *
      (gl_ModelViewMatrix * gl_Vertex).xyz +
      gbufferModelViewInverse[3].xyz;

    vec3 worldpos = position + cameraPosition;

    #ifndef NETHER
      is_foliage = 0.0;
    #endif

    if (mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      #ifndef NETHER
        is_foliage = .4;
      #endif

      float weight = gl_MultiTexCoord0.t < mc_midTexCoord.t ? 1.0 : 0.0;

      if (mc_Entity.x == ENTITY_UPPERGRASS) {
        weight += 1.0;
      } else if (mc_Entity.x == ENTITY_LEAVES) {
        weight = .3;
      } else if (mc_Entity.x == ENTITY_SMALLENTS && (weight > 0.9 || fract(worldpos.y + 0.0675) > 0.01)) {
        weight = 1.0;
      }

      weight *= lmcoord.y;  // Evitamos movimiento en cuevas
      position.xyz += wave_move(worldpos.xz) * weight * (0.03 + (rainStrength * .05));
    }

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);

  #else  // Normal position
    #ifndef NETHER
      is_foliage = 0.0;
      if (mc_Entity.x == ENTITY_LOWERGRASS ||
          mc_Entity.x == ENTITY_UPPERGRASS ||
          mc_Entity.x == ENTITY_SMALLGRASS ||
          mc_Entity.x == ENTITY_SMALLENTS ||
          mc_Entity.x == ENTITY_LEAVES)
      {
        is_foliage = .4;
      }
    #endif

    vec3 position =
      mat3(gbufferModelViewInverse) *
      (gl_ModelViewMatrix * gl_Vertex).xyz +
      gbufferModelViewInverse[3].xyz;

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);

  #endif

#else
  #ifndef NO_SHADOWS
    #ifdef SHADOW_CASTING
      vec3 position =
        mat3(gbufferModelViewInverse) *
        (gl_ModelViewMatrix * gl_Vertex).xyz +
        gbufferModelViewInverse[3].xyz;
    #endif
  #endif

  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

#endif

#if AA_TYPE == 1
  gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
#endif

gl_FogFragCoord = length(gl_Position.xyz);

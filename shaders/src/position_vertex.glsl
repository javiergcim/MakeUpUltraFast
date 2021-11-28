// Waving plants calculation
#ifdef FOLIAGE_V
  #if WAVING == 1
    vec4 position =
      (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);

    vec3 worldpos = position.xyz + cameraPosition;

    #ifndef NETHER
      is_foliage = 0.0;
    #endif

    if (
        mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      #ifndef NETHER
        is_foliage = .4;
      #endif

      float weight = float(gl_MultiTexCoord0.t < mc_midTexCoord.t);

      if (mc_Entity.x == ENTITY_UPPERGRASS) {
        weight += 1.0;
      } else if (mc_Entity.x == ENTITY_LEAVES) {
        weight = .3;
      } else if (mc_Entity.x == ENTITY_SMALLENTS && (weight > 0.9 || fract(worldpos.y + 0.0675) > 0.01)) {
        weight = 1.0;
      }

      weight *= lmcoord.y * lmcoord.y;  // Evitamos movimiento en cuevas
      position.xyz += wave_move(worldpos.xzy) * weight * (0.03 + (rainStrength * .05));
    }

    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

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
    vec4 position =
      (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);

    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

  #endif

#else
  #ifndef NO_SHADOWS
    #ifdef SHADOW_CASTING
      vec4 position =
        gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    #endif
  #endif

  #ifdef SHADER_LINE
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  #else
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  #endif

#endif

#ifdef EMMISIVE_V
  float is_fake_emmisor = 0.0;
  if (mc_Entity.x == ENTITY_F_EMMISIVE)
  {
    is_fake_emmisor = 1.0;
  }
#endif

#if AA_TYPE == 1
  gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
#endif

#ifndef SHADER_BASIC
  gl_FogFragCoord = length(gl_Position.xyz);
#endif

// Waving plants calculation
#ifdef FOLIAGE_V
  #if WAVING == 1
    vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
    vec4 position =
      gbufferModelViewInverse * sub_position;

    vec3 worldpos = position.xyz + cameraPosition;

    is_foliage = 0.0;

    if (
        mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      is_foliage = .4;

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
    is_foliage = 0.0;
    if (mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      is_foliage = .4;
    }

    vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
    vec4 position =
      gbufferModelViewInverse * sub_position;

    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

  #endif

#else
  vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
  #ifndef NO_SHADOWS
    #ifdef SHADOW_CASTING
      vec4 position =
        gbufferModelViewInverse * sub_position;
    #endif
  #endif

  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

#endif

#ifdef EMMISIVE_V
  float is_fake_emmisor = 0.0;
  if (mc_Entity.x == ENTITY_F_EMMISIVE)
  {
    is_fake_emmisor = 1.0;
  }
#endif

#if AA_TYPE > 1
  gl_Position.xy += taa_offset * gl_Position.w;
#endif

#ifndef SHADER_BASIC
    vec3 viewPos = gl_Position.xyz / gl_Position.w;
    vec4 homopos = gbufferProjectionInverse * vec4(viewPos, 1.0);
    viewPos = homopos.xyz / homopos.w;
  #if defined GBUFFER_CLOUDS
    gl_FogFragCoord = length(viewPos.xz);
  #else
    gl_FogFragCoord = length(viewPos.xyz);
  #endif
#endif

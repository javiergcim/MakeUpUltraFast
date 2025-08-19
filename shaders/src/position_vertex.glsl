gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

#ifdef FOLIAGE_V  // Lógica optimizada para follaje y bloques generales
    
    is_foliage = 0.0;

    // Comprobamos si la entidad actual es un tipo de follaje.
    bool isFoliageEntity = (
        mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES ||
        mc_Entity.x == ENTITY_SMALLENTS_NW
    );

    vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
    vec4 position = gbufferModelViewInverse * sub_position;
    
    if (isFoliageEntity) {
        is_foliage = 0.4;

        #if WAVING == 1
            if (mc_Entity.x != ENTITY_SMALLENTS_NW) {
                vec3 worldpos = position.xyz + cameraPosition;

                // Lógica original para calcular el peso del movimiento
                float weight = float(gl_MultiTexCoord0.t < mc_midTexCoord.t);

                if (mc_Entity.x == ENTITY_UPPERGRASS) {
                    weight += 1.0;
                } else if (mc_Entity.x == ENTITY_LEAVES) {
                    weight = .3;
                } else if (mc_Entity.x == ENTITY_SMALLENTS && (weight > 0.9 || fract(worldpos.y + 0.0675) > 0.01)) {
                    weight = 1.0;
                }

                weight *= lmcoord.y * lmcoord.y;
                
                // Calculamos el DESPLAZAMIENTO y lo añadimos a la posición base ya calculada.
                vec3 wave_offset_world = wave_move(worldpos.xzy) * weight * (0.03 + (rainStrength * .05));
                vec4 wave_offset_clip = gl_ModelViewProjectionMatrix * vec4(wave_offset_world, 0.0);
                
                gl_Position += wave_offset_clip;
            }
        #endif
    }

#else // Lógica para cuando no es un shader con follaje (p. ej. entidades)

    vec4 sub_position = gl_ModelViewMatrix * gl_Vertex;
    #ifndef NO_SHADOWS
        #ifdef SHADOW_CASTING
            vec4 position = gbufferModelViewInverse * sub_position;
        #endif
    #endif
    
#endif

#ifdef EMMISIVE_V
    float is_fake_emmisor = float(mc_Entity.x == ENTITY_F_EMMISIVE);
#endif

#if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
#endif

#ifndef SHADER_BASIC
    vec4 homopos = gbufferProjectionInverse * vec4(gl_Position.xyz / gl_Position.w, 1.0);
    vec3 viewPos = homopos.xyz / homopos.w;

    #if defined GBUFFER_CLOUDS
        gl_FogFragCoord = length(viewPos.xz);
    #else
        gl_FogFragCoord = length(viewPos.xyz);
    #endif
#endif
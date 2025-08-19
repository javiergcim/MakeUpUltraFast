position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

if(dhMaterialId == DH_BLOCK_WATER) {  // Water
    position.y -= 0.125;
}

gl_Position = dhProjection * gbufferModelView * position;

#if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
#endif

// Fog intensity calculation
#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
#else
    float fog_density_coeff = day_blend_float(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT
    ) * FOG_ADJUST;
#endif

gl_FogFragCoord = length(position.xyz);

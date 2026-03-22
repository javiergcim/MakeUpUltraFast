#include "/lib/config.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"
#include "/lib/dither.glsl"

/* Color utils */

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

layout(location = 0) out vec4 gbufferData0;
layout(location = 1) out vec4 gbufferData1;

/*
struct VoxyFragmentParameters {
	vec4 sampledColour;
	vec2 tile;
	vec2 uv;
	uint face;
	uint modelId;
	vec2 lightMap;
	vec4 tinting;
	uint customId;
};
*/

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    // Re-assign

    uint face = parameters.face;
    uint customId = parameters.customId;
    
    // Includes

    #include "/src/hi_sky_voxy.glsl"

    // -- Position Vertex

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float fogDensityCoeff = FOG_DENSITY * FOG_ADJUST;
    #else
        float fogDensityCoeff = dayBlendFloat(
            FOG_SUNSET,
            FOG_DAY,
            FOG_NIGHT
        ) * FOG_ADJUST;
    #endif

    // ---- Original Light Vertex Logic

    // Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
    #if defined THE_END || defined NETHER
        vec2 illumination = vec2(parameters.lightMap.x, 1.0);
    #else
        vec2 illumination = parameters.lightMap;
    #endif

    illumination.y = max(illumination.y - 0.065, 0.0) * 1.06951871657754;
    float visibleSky = clamp(illumination.y, 0.0, 1.0);

    #if defined UNKNOWN_DIM
        visibleSky = (visibleSky * 0.6) + 0.4;
    #endif

    // Intensidad y color de luz de candelas
    float candle_luma = illumination.x * sqrt(illumination.x);
    vec3 candleColor = CANDLE_BASELIGHT * (candle_luma + sixthPow(illumination.x * 1.17));
    candleColor = clamp(candleColor, vec3(0.0), vec3(4.0));

    // Atenuación por dirección de luz directa ===================================
    #if defined THE_END || defined NETHER
        vec3 astroVector = normalize(vxModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
    #else
        vec3 astroVector = normalize(sunPosition);
    #endif

    // vec3 normal = gl_NormalMatrix * gl_Normal;
    vec3 normal = vec3(uint((face>>1)==2), uint((face>>1)==0), uint((face>>1)==1)) * (float(int(face)&1)*2-1);
    float astroLightStrength;

    // Comprobar la longitud al cuadrado (dot product) es mucho más rápido que la longitud (sqrt).
    if (dot(normal, normal) > 0.0001) {  // Workaround for undefined normals
        normal = normalize(normal);
        astroLightStrength = dot(normal, astroVector);
    } else {
        normal = vec3(0.0, 1.0, 0.0);
        astroLightStrength = 1.0;
    }

    #if defined THE_END || defined NETHER
        float directLightStrength = astroLightStrength;
    #else
        float directLightStrength = mix(-astroLightStrength, astroLightStrength, dayNightMix);
    #endif

    // Omni light intensity changes by angle
    float omniStrength = ((directLightStrength + 1.0) * 0.25) + 0.75;     

    // Calculamos color de luz directa
    #ifdef UNKNOWN_DIM
        vec3 directLightColor = texture2D(lightmap, vec2(0.0, parameters.lightMap.y)).rgb;
    #else
        vec3 directLightColor = dayBlend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
        #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
            directLightColor += (endFlashIntensity * endFlashIntensity * 0.1);
        #endif
    #endif

    directLightStrength = clamp(directLightStrength, 0.0, 1.0);

    #if defined THE_END || defined NETHER
        vec3 omniLight = LIGHT_DAY_COLOR;
    #else
        directLightColor = mix(directLightColor, ZENITH_SKY_RAIN_COLOR * luma(directLightColor) * 0.4, rainStrength);

        // Minimal light
        vec3 omniColor = mix(ZenithSkyColorRGB, directLightColor * 0.45, OMNI_TINT);
        float omniColorLuma = colorAverage(omniColor);
        
        // --- OPTIMIZACIÓN #3: Prevenir división por cero ---
        float lumaRatio = AVOID_DARK_LEVEL / max(omniColorLuma, 0.0001);
        
        vec3 omniColorMin = omniColor * lumaRatio;
        omniColor = max(omniColor, omniColorMin);
        
        vec3 omniLight = mix(omniColorMin, omniColor, visibleSky) * omniStrength;
    #endif

    if (isEyeInWater == 0) {
        // Reemplazar pow(x, 10.0) con multiplicaciones ---
        // Esto es órdenes de magnitud más rápido. x^10 = (x^2)^2 * x^2
        float visSky2 = visibleSky * visibleSky;     // x^2
        float visSky4 = visSky2 * visSky2;       // x^4
        float visSky8 = visSky4 * visSky4;       // x^8
        float vis_sky_10 = visSky8 * visSky2;      // x^10
        directLightStrength = mix(0.0, directLightStrength, vis_sky_10);
    } else {
        directLightStrength = mix(0.0, directLightStrength, visibleSky);
    }

    if (customId == ENTITY_EMMISIVE) {
        directLightStrength = 10.0;
    } else if (customId == ENTITY_S_EMMISIVE) {
        directLightStrength = 1.0;
    }

    // Fog Vertex

    // 1. Reconstruir posición en clip space
    vec2 ndc = (gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0;
    float depth = gl_FragCoord.z * 2.0 - 1.0;
    vec4 clipPos = vec4(ndc, depth, 1.0);

    // 2. Pasar a world space
    vec4 worldPos = vxViewProjInv * clipPos;
    worldPos /= worldPos.w;

    // 3. La distancia desde la cámara (equivalente a gl_FogFragCoord)
    float fogFragCoord = length(worldPos.xyz);

    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);

    #if !defined THE_END && !defined NETHER
        float fogIntensityCoeff = max(eyeBrightSmoothFloat.y * 0.004166666666666667, visibleSky);
        float frogAdjust = pow(
            clamp(fogFragCoord / float(vxRenderDistance), 0.0, 1.0) * fogIntensityCoeff,
            mix(fogDensityCoeff * 0.15, 0.5, rainStrength)
        );
    #else
        float frogAdjust = sqrt(clamp(fogFragCoord / float(vxRenderDistance), 0.0, 1.0));
    #endif

    // ---- Original Fragment Logic

    #if AA_TYPE > 0 
        float dither = shiftedRDither(gl_FragCoord.xy);
    #else
        float dither = rDither(gl_FragCoord.xy);
    #endif




    gbufferData0 = parameters.sampledColour * parameters.tinting;
    gbufferData1 = parameters.sampledColour * parameters.tinting;
}
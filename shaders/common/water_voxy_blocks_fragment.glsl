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

#include "/lib/water_voxy.glsl"

layout(location = 0) out vec4 gbufferData0;

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
    // "Uniforms" Voxy no recalcula en cada frame algujnos uniforms
    float hour_world = worldTime * 0.001;
    float dayMomentV = hour_world * 0.04166666666666667;

    float moment_aux = dayMomentV - 0.25;
    float moment_aux_2 = moment_aux * moment_aux;
    float dayMixerV = clamp(-moment_aux_2 * 20.0 + 1.25, 0.0, 1.0);

    float moment_aux_3 = dayMomentV - 0.75;
    float moment_aux_4 = moment_aux_3 * moment_aux_3;
    float nightMixerV = clamp(-moment_aux_4 * 50.0 + 3.125, 0.0, 1.0);

    // Re-assign

    uint face = parameters.face;
    uint customId = parameters.customId;
    vec4 tintColor = parameters.tinting;

    // Includes

    #include "/src/hi_sky_voxy.glsl"
    #include "/src/low_sky_voxy.glsl"

    // -- Position Vertex

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float fogDensityCoeff = FOG_DENSITY * FOG_ADJUST;
    #else
        float fogDensityCoeff = dayBlendFloatVoxy(
            FOG_SUNSET,
            FOG_DAY,
            FOG_NIGHT,
            dayMixerV,
            nightMixerV,
            dayMomentV,
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













    // Fog Vertex

    // 1. Reconstruir posición en clip space
    vec2 ndc = (gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0;
    float depth = gl_FragCoord.z * 2.0 - 1.0;
    vec4 clipPos = vec4(ndc, depth, 1.0);

    // 2. Pasar a world space
    vec4 worldPos = vxViewProjInv * clipPos;
    worldPos /= worldPos.w;

    vec4 worldposition = worldPos + vec4(cameraPosition, 0.0);  // Posición de mundo absoluta

    // 3. La distancia desde la cámara (equivalente a gl_FogFragCoord)
    float fogFragCoord = length(worldPos.xyz);

    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);

    #if !defined THE_END && !defined NETHER
        float fogIntensityCoeff = max(eyeBrightSmoothFloat.y * 0.004166666666666667, visibleSky);
        float frogAdjust = pow(
            clamp(fogFragCoord / float(vxRenderDistance * 16), 0.0, 1.0) * fogIntensityCoeff,
            mix(fogDensityCoeff * 0.15, 0.5, rainStrength)
        );
    #else
        float frogAdjust = sqrt(clamp(fogFragCoord / float(vxRenderDistance * 16), 0.0, 1.0));
    #endif

    // ---- Original Fragment Logic

    vec4 blockColor;
    vec3 realLight;

    #ifdef VANILLA_WATER
        vec3 waterNormalBase = vec3(0.0, 0.0, 1.0);
    #else
        vec3 waterNormalBase = normal_waves_voxy(worldposition.xzy);
    #endif






    // Temporal
    blockColor = parameters.sampledColour * parameters.tinting;

    #include "/src/finalcolor_voxy.glsl"

    gbufferData0 = blockColor;
}
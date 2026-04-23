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

    // -- Position Vertex





    // ---- Original Fragment Logic






    gbufferData0 = parameters.sampledColour * parameters.tinting;
}
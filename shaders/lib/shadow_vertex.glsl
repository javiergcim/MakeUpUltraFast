#define diag3(mat) vec3((mat)[0].x, (mat)[1].y, (mat)[2].z)

vec3 get_shadow_pos(in vec3 shadow_pos, in vec3 normal, float NdotL){
	shadow_pos = mat3(shadowModelView) * shadow_pos + shadowModelView[3].xyz;
	shadow_pos = diag3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

	float distortion = ((1.0 - SHADOW_BIAS) + length(shadow_pos.xy * 1.25) * SHADOW_BIAS) * 0.85;
	shadow_pos.xy /= distortion;

	float bias = distortion * distortion * (0.0046 * tan(acos(NdotL)));

	shadow_pos.xyz = shadow_pos.xyz * 0.5 + 0.5;
	shadow_pos.z -= bias;

	return shadow_pos.xyz;
}

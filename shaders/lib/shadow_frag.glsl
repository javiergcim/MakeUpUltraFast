float get_shadow(vec3 the_shadow_pos) {
	float shadow_sample = 1.0;

	if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
		  the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
			the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {

		#if SHADOW_TYPE == 0  // Pixelated
			shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
		#elif SHADOW_TYPE == 1  // Soft

			float new_z;
			shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
			if (shadowMapResolution == 256) {
				new_z = the_shadow_pos.z - .00045;

				// vec2 offset = vec2(halton[i] / shadowMapResolution * SHADOW_SMOOTH);

				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.00390625, 0.00390625), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0, 0.00390625), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.00390625, 0.00390625), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.00390625, 0.0), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.00390625, 0.0), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.00390625, -0.00390625), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0, -0.00390625), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.00390625, -0.00390625), new_z)).r;
			} else if (shadowMapResolution == 512) {
				new_z = the_shadow_pos.z - .00015;

				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0004882812, -0.0014648438), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0004882812, 0.0014648438), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0024414062, 0.0004882812), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0014648438, -0.0024414062), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0024414062, 0.0024414062), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0034179688, -0.0004882812), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0014648438, 0.0034179688), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0034179688, -0.0034179688), new_z)).r;
			} else if (shadowMapResolution == 1024) {
				new_z = the_shadow_pos.z;

				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0002441406, -0.0007324219), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0002441406, 0.0007324219), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0012207031, 0.0002441406), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0007324219, -0.0012207031), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0012207031, 0.0012207031), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0017089844, -0.0002441406), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0007324219, 0.0017089844), new_z)).r;
				shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0017089844, -0.0017089844), new_z)).r;
			}

			// Average
			shadow_sample *= 0.111111111111111;
		#endif

		shadow_sample = mix(1.0, shadow_sample, shadow_force);
		shadow_sample = (shadow_sample * .5) + .5;
	}

	return shadow_sample;
}

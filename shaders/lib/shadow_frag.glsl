vec3 get_shadow(vec3 the_shadow_pos, float NdotL) {
	vec3 shadow_color = vec3(1.0, 1.0, 1.0);

	if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
		  the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
			the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {
				float shadow_sample = shadow2D(shadowtex1, the_shadow_pos).x;

				// Vecindad
				float inv_res = 1.0 / shadowMapResolution;
				float offset = 0.0002;
				float sum = 0.0;
				sum += shadow2D(shadowtex1, vec3(vec2(-.75, -.75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(0.0, -.75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(.75, -.75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(-.75, 0.0) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(.75, 0.0) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(-.75, .75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(0.0, .75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				sum += shadow2D(shadowtex1, vec3(vec2(-.75, .75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;

				sum *= 0.125;
				shadow_sample = (shadow_sample + (2.0 * sum)) * 0.33333333333;
				shadow_sample = clamp(shadow_sample * 1.5, 0.0, 1.0);


				// vec2 offset = vec2(0.25, -0.25) / shadowMapResolution;
				// float shadow_sample = clamp(dot(vec4(shadow2D(shadowtex1,vec3(the_shadow_pos.xy + offset.xx, the_shadow_pos.z)).x,
				// 		  shadow2D(shadowtex1,vec3(the_shadow_pos.xy + offset.yx, the_shadow_pos.z)).x,
				// 		  shadow2D(shadowtex1,vec3(the_shadow_pos.xy + offset.xy, the_shadow_pos.z)).x,
				// 		  shadow2D(shadowtex1,vec3(the_shadow_pos.xy + offset.yy, the_shadow_pos.z)).x),vec4(0.25))*NdotL,0.0,1.0);

				// shadow_sample = (shadow_sample * .25) + .75;
				shadow_sample = (shadow_sample * .5) + .5;
				shadow_color = vec3(shadow_sample);
	}

	return shadow_color;
}

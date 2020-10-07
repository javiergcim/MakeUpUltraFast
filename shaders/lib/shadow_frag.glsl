vec3 get_shadow(vec3 the_shadow_pos) {
	vec3 shadow_color = vec3(1.0, 1.0, 1.0);

	if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
		  the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
			the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {
				float shadow_sample = shadow2D(shadowtex0, the_shadow_pos).x;
				shadow_color = vec3(shadow_sample);
	}

	return shadow_color;
}

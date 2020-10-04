vec3 motion_blur(vec3 color, float z_depth, float dither) {
	if (z_depth > 0.56) {
		float mbwg = 0.0;
		vec2 double_pixel = 2.0 / vec2(viewWidth, viewHeight);
		vec3 mblur = vec3(0.0);

		vec4 current_position = vec4(texcoord, z_depth, 1.0) * 2.0 - 1.0;

		vec4 view_pos = gbufferProjectionInverse * current_position;
		view_pos = gbufferModelViewInverse * view_pos;
		view_pos /= view_pos.w;

		vec3 camera_offset = cameraPosition - previousCameraPosition;

		vec4 previous_position = view_pos + vec4(camera_offset, 0.0);
		previous_position = gbufferPreviousModelView * previous_position;
		previous_position = gbufferPreviousProjection * previous_position;
		previous_position /= previous_position.w;

		vec2 blur_velocity = (current_position - previous_position).xy;
		// blur_velocity = blur_velocity / (1.0 + length(blur_velocity)) * MOTION_BLUR_STRENGTH * 0.02;
		blur_velocity = blur_velocity / (1.0 + length(blur_velocity)) * 5.0 * 0.02;

		vec2 coord = texcoord - blur_velocity * (1.5 + dither);
		for(int i = 0; i < 5; i++, coord += blur_velocity){
			vec2 sample_coord = clamp(coord, double_pixel, 1.0 - double_pixel);
			float mask = float(texture2D(depthtex0, sample_coord).r > 0.56);
			mblur += texture2DLod(colortex2, sample_coord, 0.0).rgb * mask;
			mbwg += mask;
		}
		mblur /= max(mbwg, 1.0);

		return mblur;
	} else {
		return color;
	}
}

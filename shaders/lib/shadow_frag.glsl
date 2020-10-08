#define SMOOTH_SHADOWS 2.0

vec3 get_shadow(vec3 the_shadow_pos, float NdotL) {
	vec3 shadow_color = vec3(1.0, 1.0, 1.0);

	if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
		  the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
			the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {

				vec2[28] samplePoints = vec2[28](
				  vec2(-0.533756f, 0.5918049f),
				  vec2(-0.5887652f, 0.2827983f),
				  vec2(-0.1112829f, 0.8347653f),
				  vec2(-0.1763154f, 0.4841528f),
				  vec2(0.14189f, 0.3237082f),
				  vec2(0.2800929f, 0.9120663f),
				  vec2(0.1093863f, 0.6212762f),
				  vec2(-0.9064262f, -0.1183883f),
				  vec2(-0.6078327f, -0.178559f),
				  vec2(-0.357408f, 0.1051248f),
				  vec2(0.6527902f, 0.5192569f),
				  vec2(0.09694252f, 0.03230363f),
				  vec2(-0.674222f, -0.7260616f),
				  vec2(-0.2918845f, -0.4964681f),
				  vec2(-0.7958741f, -0.4429268f),
				  vec2(-0.1453472f, -0.204167f),
				  vec2(0.4898141f, 0.1773323f),
				  vec2(0.9270607f, 0.3427289f),
				  vec2(0.2821047f, -0.2190978f),
				  vec2(-0.8921345f, 0.221567f),
				  vec2(0.7761434f, -0.4868898f),
				  vec2(0.7591619f, -0.1604567f),
				  vec2(0.2184547f, -0.7292697f),
				  vec2(-0.33626f, -0.8815288f),
				  vec2(-0.8542173f, 0.5196956f),
				  vec2(0.03850133f, -0.9906212f),
				  vec2(0.5087105f, -0.7317122f),
				  vec2(0.08914156f, -0.438681f)
				);

				float shadowBias = 0.0005f;
				float shadow_sample = 0.0;

				for(int i = 0; i < samplePoints.length(); i++){
			    vec2 offset = vec2(samplePoints[i] / shadowMapResolution * SMOOTH_SHADOWS);
			    // offset *= rotationMatrix;

			    float shadowMapSample = shadow2D(shadowtex1, vec3(the_shadow_pos.st + offset, the_shadow_pos.z)).r;
			    float visibility = step(the_shadow_pos.z - shadowMapSample, shadowBias);

			    // vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
			    // shadowColor += colorSample + visibility * SUNLIGHT_STRENGTH;
					shadow_sample += visibility;
			  }
				//
			  shadow_sample = shadow_sample / samplePoints.length();


























				// float shadow_sample = shadow2D(shadowtex1, the_shadow_pos).x;

				// Vecindad
				// float inv_res = 1.0 / shadowMapResolution;
				// float offset = 0.0002;
				// float sum = 0.0;
				// sum += shadow2D(shadowtex1, vec3(vec2(-.75, -.75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(0.0, -.75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(.75, -.75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(-.75, 0.0) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(.75, 0.0) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(-.75, .75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(0.0, .75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				// sum += shadow2D(shadowtex1, vec3(vec2(-.75, .75) * inv_res + the_shadow_pos.xy, the_shadow_pos.z - offset)).x;
				//
				// sum *= 0.125;
				// shadow_sample = (shadow_sample + (2.0 * sum)) * 0.33333333333;
				// shadow_sample = clamp(shadow_sample * 1.5, 0.0, 1.0);


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

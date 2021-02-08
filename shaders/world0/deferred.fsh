#version 130
/* MakeUp Ultra Fast - composite.fsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float rainStrength;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float blindness;

#if AO == 1
  uniform float inv_aspect_ratio;
	uniform float fov_y_inv;
#endif

#if V_CLOUDS != 0
  uniform sampler2D gaux3;
  uniform vec3 cameraPosition;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform float pixel_size_x;
	uniform float pixel_size_y;
	uniform vec3 sunPosition;
#endif

#if AO == 1 || V_CLOUDS != 0
  uniform mat4 gbufferProjection;
  uniform float frameTimeCounter;
	uniform sampler2D colortex5;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

#if AO == 1 || V_CLOUDS != 0
  #include "/lib/dither.glsl"
#endif

#if AO == 1
  #include "/lib/ao.glsl"
#endif

#if V_CLOUDS != 0
  #include "/lib/projection_utils.glsl"
  #include "/lib/volumetric_clouds.glsl"
#endif

void main() {
  vec4 block_color = texture(colortex0, texcoord);
  float d = texture(depthtex0, texcoord).r;
  float linear_d = ld(d);

  #if V_CLOUDS != 0
    if (linear_d > 0.9999) {  // Only sky
      vec4 screen_pos =
				vec4(
					gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
					gl_FragCoord.z,
					1.0
				);
  		vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

  		vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
  		vec3 view_vector = normalize(world_pos.xyz);

			float bright =
				dot(
					view_vector,
					normalize((gbufferModelViewInverse * vec4(sunPosition, 0.0)).xyz)
				);
			bright = clamp(bright * bright * bright, 0.0, 1.0);

			// block_color.rgb *= (bright * .25 + 1.0);

      block_color.rgb =
				get_cloud(view_vector, block_color.rgb, bright);
    }
  #endif

  #if AO == 1
    // AO distance attenuation
    float fog_density_coeff = mix(
      fog_density[current_hour_floor],
      fog_density[current_hour_ceil],
      current_hour_fract
      );

    float ao_att = pow(
      linear_d,
      mix(fog_density_coeff * .5, .25, rainStrength)
    );

    float final_ao = mix(dbao(), 1.0, ao_att);
    block_color.rgb *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
    // block_color = vec4(vec3(linear_d), 1.0);
  #endif

  // Niebla
  if (isEyeInWater == 1) {
    vec3 hi_sky_color = day_color_mixer(
      HI_MIDDLE_COLOR,
      HI_DAY_COLOR,
      HI_NIGHT_COLOR,
      day_moment
      );

    hi_sky_color = mix(
      hi_sky_color,
      HI_SKY_RAIN_COLOR * luma(hi_sky_color),
      rainStrength
    );

    block_color.rgb = mix(
      block_color.rgb,
      hi_sky_color * .5 * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667),
      sqrt(linear_d)
      );
  } else if (isEyeInWater == 2) {
    block_color = mix(
      block_color,
      vec4(1.0, .1, 0.0, 1.0),
      sqrt(linear_d)
      );
  }

	/* DRAWBUFFERS:04 */
	gl_FragData[0] = vec4(block_color.rgb, d);
	gl_FragData[1] = block_color;
	gl_FragData[4] = block_color;
}

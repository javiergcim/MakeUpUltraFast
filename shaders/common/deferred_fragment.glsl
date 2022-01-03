/* Exits */
out vec4 outColor0;
out vec4 outColor1;

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform sampler2D gaux2;

#ifdef NETHER
  uniform vec3 fogColor;
#endif

#if AO == 1
  uniform float inv_aspect_ratio;
  uniform float fov_y_inv;
#endif

#if V_CLOUDS != 0
  uniform sampler2D noisetex;
  uniform vec3 cameraPosition;
  uniform vec3 sunPosition;
#endif

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float pixel_size_x;
uniform float pixel_size_y;

#if AO == 1 || V_CLOUDS != 0
  uniform mat4 gbufferProjection;
  uniform int frame_mod;
  uniform float frameTimeCounter;
#endif

in vec2 texcoord;
flat in vec3 up_vec;  // Flat

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

  #ifdef THE_END
    #include "/lib/volumetric_clouds_end.glsl"
  #else
    #include "/lib/volumetric_clouds.glsl"
  #endif
  
#endif

void main() {
  vec4 block_color = texture(colortex0, texcoord);
  float d = texture(depthtex0, texcoord).r;
  float linear_d = ld(d);

  vec3 view_vector;

  #if AO == 1 || V_CLOUDS != 0
    #if AA_TYPE > 0
      float dither = shifted_eclectic_dither(gl_FragCoord.xy);
    #else
      float dither = eclectic_dither(gl_FragCoord.xy);
    #endif
  #endif

  #if V_CLOUDS != 0 && !defined NO_CLOUDY_SKY
    if (linear_d > 0.9999) {  // Only sky
      vec4 world_pos =
        gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
      view_vector = normalize(world_pos.xyz);

      #ifdef THE_END
        float bright =
          dot(view_vector, normalize(vec3(0.0, 0.89442719, 0.4472136)));
        bright = clamp((bright * 2.0) - 1.0, 0.0, 1.0);
        bright *= bright * bright * bright;
      #else
        float bright =
          dot(
            view_vector,
            normalize((gbufferModelViewInverse * vec4(sunPosition, 0.0)).xyz)
          );
        bright = clamp(bright * bright * bright, 0.0, 1.0);
      #endif

      #ifdef THE_END
        block_color = vec4(HI_DAY_COLOR, 1.0);
        block_color.rgb =
          get_end_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG);
      #else
        block_color.rgb =
          get_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG);
      #endif
    }

  #else
    #if defined THE_END
      if (linear_d > 0.9999) {  // Only sky
        block_color = vec4(HI_DAY_COLOR, 1.0);
      }
    #elif defined NETHER
      if (linear_d > 0.9999) {  // Only sky
        block_color = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
      }
    #else
      if (linear_d > 0.9999 && isEyeInWater == 1) {  // Only sky and water
        vec4 screen_pos =
          vec4(
            gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
            gl_FragCoord.z,
            1.0
          );
        vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

        vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
        view_vector = normalize(world_pos.xyz);
      }
    #endif    
  #endif

  #if AO == 1
    #if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
      float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
    #else
      float fog_density_coeff = mix(
        fog_density[current_hour_floor],
        fog_density[current_hour_ceil],
        current_hour_fract
        ) * FOG_ADJUST;
    #endif

    // AO distance attenuation
    float ao_att = pow(
      clamp(linear_d * 1.4, 0.0, 1.0),
      mix(fog_density_coeff, .5, rainStrength)
    );

    float final_ao = mix(dbao(dither), 1.0, ao_att);
    block_color.rgb *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
    // block_color = vec4(vec3(linear_d), 1.0);
  #endif

  #if defined THE_END || defined NETHER
    #define NIGHT_CORRECTION 1.0
  #else
    #define NIGHT_CORRECTION day_blend_float(1.0, 1.0, 0.1)
  #endif

  // Cielo bajo el agua
  if (isEyeInWater == 1) {
    if (linear_d > 0.9999) {
      block_color.rgb = mix(
        NIGHT_CORRECTION * WATER_COLOR * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667),
        block_color.rgb,
        max(clamp(view_vector.y - 0.1, 0.0, 1.0), rainStrength)
      );
    }
  }

  /* DRAWBUFFERS:14 */
  outColor0 = vec4(block_color.rgb, d);
  outColor1 = block_color;
}

/* Exits */
out vec4 outColor0;

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
// uniform sampler2D gaux4;
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

#if V_CLOUDS != 0 && !defined UNKNOWN_DIM
  uniform sampler2D noisetex;
  uniform vec3 cameraPosition;
  uniform vec3 sunPosition;
#endif

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

#if AO == 1 || (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
  uniform mat4 gbufferProjection;
  uniform int frame_mod;
  uniform float frameTimeCounter;
#endif

in vec2 texcoord;
flat in vec3 up_vec;  // Flat

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"

#if AO == 1 || (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
  #include "/lib/dither.glsl"
#endif

#if AO == 1
  #include "/lib/ao.glsl"
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
  #include "/lib/projection_utils.glsl"

  #ifdef THE_END
    #include "/lib/volumetric_clouds_end.glsl"
  #else
    #include "/lib/volumetric_clouds.glsl"
  #endif
  
#endif

void main() {
  float d = texture(depthtex0, texcoord).r;
  float linear_d = ld(d);

  vec4 effects_color = vec4(texture(colortex0, texcoord).rgb, 1.0);

  vec3 view_vector;

  #if AO == 1 || (V_CLOUDS != 0 && !defined UNKNOWN_DIM)
    #if AA_TYPE > 0
      float dither = shifted_eclectic_makeup_dither(gl_FragCoord.xy);
    #else
      float dither = eclectic_makeup_dither(gl_FragCoord.xy);
    #endif
  #endif

  #if AO == 1
    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
      float fog_density_coeff = FOG_DENSITY * FOG_ADJUST;
    #else
      float fog_density_coeff = day_blend_float(
        FOG_MIDDLE,
        FOG_DAY,
        FOG_NIGHT
      ) * FOG_ADJUST;
    #endif

    // AO distance attenuation
    float ao_att = pow(
      clamp(linear_d * 1.4, 0.0, 1.0),
      mix(fog_density_coeff, 1.0, rainStrength)
    );

    float final_ao = mix(dbao(dither), 1.0, ao_att);
  #endif

  #if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
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
        effects_color.rgb =
          get_end_cloud(view_vector, effects_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG);
      #else
        effects_color.rgb =
          get_cloud(view_vector, effects_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG);
      #endif
    }
  #endif

  /* DRAWBUFFERS:6 */
  #if AO == 1
    if (linear_d <= 0.9999) {
      effects_color.a = final_ao;
    }
  #endif

  outColor0 = effects_color;
}

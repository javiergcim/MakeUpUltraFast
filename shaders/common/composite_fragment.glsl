/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D depthtex0;
uniform int isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;

#if VOL_LIGHT == 1 && !defined NETHER
  uniform sampler2D depthtex1;
  uniform vec3 sunPosition;
  uniform vec3 moonPosition;
  uniform float light_mix;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 gbufferModelView;
  uniform int frame_mod;
  uniform float vol_mixer;
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
  uniform float light_mix;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 gbufferModelView;
  uniform int frame_mod;
  uniform float vol_mixer;
  uniform vec3 shadowLightPosition;
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform sampler2DShadow shadowtex1;

  #if defined COLORED_SHADOW
    uniform sampler2DShadow shadowtex0;
    uniform sampler2D shadowcolor0;
  #endif
#endif

varying vec2 texcoord;
varying float exposure_coef;

#ifdef BLOOM
  varying float exposure;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
  varying vec3 vol_light_color;
  varying vec2 lightpos;
  varying vec3 astro_pos;
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
  varying vec3 vol_light_color;
#endif

#include "/lib/depth.glsl"

#ifdef BLOOM
  #include "/lib/luma.glsl"
#endif

#if VOL_LIGHT == 1 && !defined NETHER
  #include "/lib/dither.glsl"
  #include "/lib/volumetric_light.glsl"
#endif

#if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
  #include "/lib/dither.glsl"
  #include "/lib/volumetric_light.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);
  float d = texture2D(depthtex0, texcoord).r;
  float linear_d = ld(d);

  // "Niebla" submarina
  if (isEyeInWater == 1) {
    float water_absorption =  // Distance
      2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));
    water_absorption = (1.0 / -((water_absorption * WATER_ABSORPTION) + 1.0)) + 1.0;

    block_color.rgb = mix(
      block_color.rgb,
      WATER_COLOR * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667) * (exposure_coef * 0.9 + 0.1),
      water_absorption);

  } else if (isEyeInWater == 2) {
    block_color = mix(
      block_color,
      vec4(1.0, .1, 0.0, 1.0),
      clamp(sqrt(linear_d * far * 0.125), 0.0, 1.0)
      );
  }

  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    mat4 modeli_times_projectioni = gbufferModelViewInverse * gbufferProjectionInverse;

    #if AA_TYPE > 0
      float dither = shifted_dither17(gl_FragCoord.xy);
    #else
      float dither = dither_grad_noise(gl_FragCoord.xy);
    #endif
  #endif

  // Depth to distance
  float screen_distance =
    2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));

  #if VOL_LIGHT == 1 && !defined NETHER
    #if defined THE_END
      float vol_light = 0.5;
    #else
      float vol_light = ss_godrays(dither);
    #endif

    vec4 center_world_pos =
      modeli_times_projectioni * (vec4(0.5, 0.5, 1.0, 1.0) * 2.0 - 1.0);
    vec3 center_view_vector = normalize(center_world_pos.xyz);

    vec4 world_pos =
      modeli_times_projectioni * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
    vec3 view_vector = normalize(world_pos.xyz);

    #if defined THE_END
      // Fixed light source position in sky for intensity calculation
      float vol_intensity = clamp(
        dot(
          center_view_vector,
          normalize((gbufferModelViewInverse * gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz)
        ),
        0.0,
        1.0
      );

      vol_intensity *= clamp(
        dot(
          view_vector,
          normalize((gbufferModelViewInverse * gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz)
        ),
        0.0,
        1.0
      );

      vol_intensity *= 0.666;

      block_color.rgb += (vol_light_color * vol_light * vol_intensity * 2.0);
    #else
      // Light source position for intensity calculation
      float vol_intensity =
        clamp(dot(center_view_vector, normalize((gbufferModelViewInverse * vec4(astro_pos, 0.0)).xyz)), 0.0, 1.0);
      vol_intensity *= dot(
          view_vector,
          normalize((gbufferModelViewInverse * vec4(astro_pos, 0.0)).xyz)
        );
      vol_intensity =
      pow(clamp(vol_intensity, 0.0, 1.0), vol_mixer) * 0.666 * abs(light_mix * 2.0 - 1.0);
      
      block_color.rgb =
        mix(block_color.rgb, vol_light_color * vol_light, vol_intensity * (vol_light * 0.5 + 0.5) * (1.0 - rainStrength));
    #endif
  #endif

  #if VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER
    #if defined COLORED_SHADOW
      vec3 vol_light = get_volumetric_color_light(dither, screen_distance, modeli_times_projectioni);
    #else
      float vol_light = get_volumetric_light(dither, screen_distance, modeli_times_projectioni);
    #endif

    // Ajuste de intensidad

    vec4 world_pos =
      modeli_times_projectioni * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
    vec3 view_vector = normalize(world_pos.xyz);

    #if defined THE_END
      // Fixed light source position in sky for intensity calculation
      float vol_intensity =
        dot(
          view_vector,
          normalize((gbufferModelViewInverse * gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz)
        );
    #else
      // Light source position for intensity calculation
        float vol_intensity =
          dot(
            view_vector,
            normalize((gbufferModelViewInverse * vec4(shadowLightPosition, 0.0)).xyz)
          );
    #endif

    #if defined THE_END
      vol_intensity =
        ((pow(clamp((vol_intensity + .666667) * 0.6, 0.0, 1.0), 2.0) * 0.5));
      block_color.rgb += (vol_light_color * vol_light * vol_intensity * 2.0);
    #else
      vol_intensity =
        pow(clamp(vol_intensity, 0.0, 1.0), vol_mixer) * 0.666 * abs(light_mix * 2.0 - 1.0);

      block_color.rgb =
        mix(block_color.rgb, vol_light_color * vol_light, vol_intensity * (vol_light * 0.5 + 0.5) * (1.0 - rainStrength));
    #endif
  #endif

  // Dentro de la nieve
  #ifdef BLOOM
    if (isEyeInWater == 3) {
      block_color.rgb = mix(
        block_color.rgb,
        vec3(0.7, 0.8, 1.0) / exposure,
        clamp(screen_distance * .5, 0.0, 1.0)
      );
    }
  #else
    if (isEyeInWater == 3) {
      block_color.rgb = mix(
        block_color.rgb,
        vec3(0.85, 0.9, 0.6),
        clamp(screen_distance * .5, 0.0, 1.0)
      );
    }
  #endif

  #ifdef BLOOM
    // Bloom source
    float bloom_luma =
      smoothstep(0.85, 1.0, luma(block_color.rgb * exposure)) * 0.4;

    /* DRAWBUFFERS:12 */
    gl_FragData[0] = block_color;
    gl_FragData[1] = block_color * bloom_luma;
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}
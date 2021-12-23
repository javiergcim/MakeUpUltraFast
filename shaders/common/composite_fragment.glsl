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

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D depthtex0;
uniform int isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;

#ifdef VOL_LIGHT
  // Don't delete this ifdef. It's nedded to show option in menu (Optifine bug?)
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 gbufferModelView;
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
  uniform sampler2DShadow shadowtex1;
  uniform int frame_mod;
  uniform float light_mix;
  uniform float vol_mixer;
#endif

in vec2 texcoord;
flat in float exposure_coef;

#ifdef BLOOM
  flat in float exposure;
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
  flat in vec3 vol_light_color;
#endif

#include "/lib/depth.glsl"

#ifdef BLOOM
  #include "/lib/luma.glsl"
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
  #include "/lib/volumetric_light.glsl"
  #include "/lib/dither.glsl"
#endif

void main() {
  vec4 block_color = texture(colortex1, texcoord);
  float d = texture(depthtex0, texcoord).r;
  float linear_d = ld(d);

  // "Niebla" submarina
  if (isEyeInWater == 1) {
    float water_absortion =  // Distance
      2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));
    water_absortion = (1.0 / -((water_absortion * WATER_ABSORPTION) + 1.0)) + 1.0;

    block_color.rgb = mix(
      block_color.rgb,
      WATER_COLOR * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667) * (exposure_coef * 0.9 + 0.1),
      water_absortion);

  } else if (isEyeInWater == 2) {
    block_color = mix(
      block_color,
      vec4(1.0, .1, 0.0, 1.0),
      sqrt(linear_d)
      );
  }

  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  #if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
    #if AA_TYPE > 0
      float dither = shifted_dither_grad_noise(gl_FragCoord.xy);
    #else
      float dither = dither_grad_noise(gl_FragCoord.xy);
    #endif
  #endif

  // Depth to distance
  float screen_distance =
    2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));

  #if defined VOL_LIGHT && defined SHADOW_CASTING && !defined NETHER
    float vol_light = get_volumetric_light(dither, screen_distance);

    // Ajuste de intensidad
    vec4 world_pos =
      gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
    vec3 view_vector = normalize(world_pos.xyz);

    #if defined THE_END || defined NETHER
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

    vol_intensity =
      ((pow(clamp((vol_intensity + .666667) * 0.6, 0.0, 1.0), vol_mixer) * 0.5)) * abs(light_mix * 2.0 - 1.0);

    #if defined THE_END || defined NETHER
      block_color.rgb += (vol_light_color * vol_light * vol_intensity * 2.0);
    #else
      block_color.rgb =
        mix(block_color.rgb, vol_light_color, vol_light * vol_intensity * (1.0 - rainStrength));
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
      smoothstep(0.85, 0.97, luma(block_color.rgb * exposure)) * 0.5;

    /* DRAWBUFFERS:12 */
    outColor0 = block_color;
    outColor1 = block_color * bloom_luma;
  #else
    /* DRAWBUFFERS:1 */
    outColor0 = block_color;
  #endif
}
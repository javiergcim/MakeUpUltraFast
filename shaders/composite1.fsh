#version 120
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

// #define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex5;
uniform sampler2D colortex2;
uniform float frameTimeCounter;
uniform float inv_aspect_ratio;

#ifdef VOL_LIGHT
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform float viewWidth;
  uniform float viewHeight;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform float near;
  uniform float far;
  uniform sampler2DShadow shadowtex1;
  uniform sampler2D depthtex0;
  // uniform float rainStrength;
  // uniform ivec2 eyeBrightnessSmooth;
  // uniform float current_hour_fract;
  // uniform int current_hour_floor;
  // uniform int current_hour_ceil;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#ifdef VOL_LIGHT
  varying vec3 current_fog_color;  // Flat
#endif

#include "/lib/dither.glsl"
#include "/lib/bloom.glsl"

#ifdef VOL_LIGHT
  #include "/lib/depth.glsl"
  #include "/lib/luma.glsl"
  #include "/lib/shadow_frag.glsl"
  #include "/lib/volumetric_light.glsl"
#endif

#ifdef BLOOM
  const bool colortex2MipmapEnabled = true;
#endif

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);

  #if defined BLOOM || defined VOL_LIGHT
    #if MC_VERSION >= 11300
      #if AA_TYPE > 0
        float dither = shifted_texture_noise_64(gl_FragCoord.xy, colortex5);
      #else
        float dither = texture_noise_64(gl_FragCoord.xy, colortex5);
      #endif
    #else
      #if AA_TYPE > 0
        float dither = timed_hash12(gl_FragCoord.xy);
      #else
        float dither = dither_grad_noise(gl_FragCoord.xy);
      #endif
    #endif
  #endif

  #ifdef BLOOM
    vec3 bloom = mipmap_bloom(colortex2, texcoord, dither);
    block_color.rgb += bloom;
  #endif

  #ifdef VOL_LIGHT
    float screen_distance = depth_to_distance(texture2D(depthtex0, texcoord).r);

    float vol_light = get_volumetric_light(dither, screen_distance);

    // // Fog color calculation
    // float fog_mix_level = mix(
    //   fog_color_mix[current_hour_floor],
    //   fog_color_mix[current_hour_ceil],
    //   current_hour_fract
    //   );
    //
    // // Fog intensity calculation
    // float fog_density_coeff = mix(
    //   fog_density[current_hour_floor],
    //   fog_density[current_hour_ceil],
    //   current_hour_fract
    //   );
    //
    // float fog_intensity_coeff = max(
    //   // visible_sky,
    //   1.0,
    //   eyeBrightnessSmooth.y * 0.004166666666666667
    // );
    //
    // vec3 hi_sky_color = day_blend(
    //   HI_MIDDLE_COLOR,
    //   HI_DAY_COLOR,
    //   HI_NIGHT_COLOR
    //   );
    //
    // hi_sky_color = mix(
    //   hi_sky_color,
    //   HI_SKY_RAIN_COLOR * luma(hi_sky_color),
    //   rainStrength
    // );
    //
    // vec3 low_sky_color = day_blend(
    //   LOW_MIDDLE_COLOR,
    //   LOW_DAY_COLOR,
    //   LOW_NIGHT_COLOR
    //   );
    //
    // low_sky_color = mix(
    //   low_sky_color,
    //   LOW_SKY_RAIN_COLOR * luma(low_sky_color),
    //   rainStrength
    // );
    //
    // vec3 current_fog_color =
    //   mix(hi_sky_color, low_sky_color, fog_mix_level) * fog_intensity_coeff;

    block_color.rgb = mix(block_color.rgb, current_fog_color, vol_light * .4);
    // block_color.rgb = vec3(vol_light);
  #endif

  #ifdef MOTION_BLUR
    #ifdef DOF
      /* DRAWBUFFERS:01 */
      gl_FragData[0] = block_color;
      gl_FragData[1] = block_color;
    #else
      /* DRAWBUFFERS:1 */
      gl_FragData[0] = block_color;
    #endif
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

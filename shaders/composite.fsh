#version 120
/* MakeUp - composite.fsh
Render: Bloom and volumetric light

Javier Garduño - GNU Lesser General Public License v3.0
*/

// #define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;

#ifdef VOL_LIGHT
  // Don't delete this ifdef. It's nedded to show option in menu (Optifine bug?)
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
  uniform sampler2DShadow shadowtex1;
  uniform sampler2D depthtex0;
  uniform sampler2D colortex5;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#ifdef BLOOM
  varying float exposure;  // Flat
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING
  varying vec3 vol_light_color;  // Flat
#endif

#include "/lib/depth.glsl"

#ifdef BLOOM
  #include "/lib/luma.glsl"
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING
  #include "/lib/volumetric_light.glsl"
  #include "/lib/dither.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);
  float d = block_color.a;
  float linear_d = ld(d);

  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  #if defined VOL_LIGHT && defined SHADOW_CASTING
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

  #if defined VOL_LIGHT && defined SHADOW_CASTING
    float screen_distance = depth_to_distance(texture2D(depthtex0, texcoord).r);
    float vol_light = get_volumetric_light(dither, screen_distance);

    // Ajuste de intensidad
    vec4 world_pos =
      gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
    vec3 view_vector = normalize(world_pos.xyz);

    float vol_intensity =
      dot(
        view_vector,
        normalize((gbufferModelViewInverse * vec4(shadowLightPosition, 0.0)).xyz)
      );

    vol_intensity = clamp(vol_intensity * 0.3, 0.0, 1.0) + .15;

    block_color.rgb +=
      (vol_light_color * vol_light * vol_intensity * (1.0 - rainStrength));
    // block_color.rgb = vec3(1.0);
  #endif

  #ifdef BLOOM
    // Bloom source
    float bloom_luma =
      smoothstep(0.85, 0.97, luma(block_color.rgb * exposure)) * 0.4;

    /* DRAWBUFFERS:12 */
    gl_FragData[0] = block_color;
    gl_FragData[1] = block_color * bloom_luma;
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

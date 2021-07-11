#version 120
/* MakeUp - composite.fsh
Render: Bloom and volumetric light

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform sampler2D depthtex0;

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
  uniform int frame_mod;
  uniform float light_mix;
  uniform float vol_mixer;
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
  float d = texture2D(depthtex0, texcoord).r;
  float linear_d = ld(d);

  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  #if defined VOL_LIGHT && defined SHADOW_CASTING
    #if AA_TYPE > 0
      float dither = shifted_dither_grad_noise(gl_FragCoord.xy);
    #else
      float dither = dither_grad_noise(gl_FragCoord.xy);
    #endif
  #endif

  #if defined VOL_LIGHT && defined SHADOW_CASTING
    // Depth to distance
    float screen_distance =
      2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));

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

    vol_intensity =
      ((pow(clamp((vol_intensity + .25) * 0.8, 0.0, 1.0), vol_mixer) * 0.5)) * abs(light_mix * 2.0 - 1.0);

    block_color.rgb =
      mix(block_color.rgb, vol_light_color, vol_light * vol_intensity * (1.0 - rainStrength));

    // block_color.rgb = vec3(vol_intensity);
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

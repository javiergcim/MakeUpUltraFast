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
  // Don't delete this ifdef. It's nedded to show option in menu (Optifine bug?)
#endif

#if defined VOL_LIGHT && defined SHADOW_CASTING
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform vec3 shadowLightPosition;
  uniform float rainStrength;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform float near;
  uniform float far;
  uniform sampler2DShadow shadowtex1;
  uniform sampler2D depthtex0;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if defined VOL_LIGHT && defined SHADOW_CASTING
  varying vec3 vol_light_color;  // Flat
#endif

#include "/lib/dither.glsl"
#include "/lib/bloom.glsl"

#if defined VOL_LIGHT && defined SHADOW_CASTING
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

  #if defined BLOOM || (defined VOL_LIGHT && defined SHADOW_CASTING)
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

  #if defined VOL_LIGHT && defined SHADOW_CASTING
    float screen_distance = depth_to_distance(texture2D(depthtex0, texcoord).r);
    float vol_light = get_volumetric_light(dither, screen_distance);

    // Ajuste de visibilidad
    vec4 screen_pos =
      vec4(
        gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
        gl_FragCoord.z,
        1.0
      );
    vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

    vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
    vec3 view_vector = normalize(world_pos.xyz);

    float vol_intensity =
      dot(
        view_vector,
        normalize((gbufferModelViewInverse * vec4(shadowLightPosition, 0.0)).xyz)
      );

    vol_intensity = clamp(vol_intensity * 0.3, 0.0, 1.0) + .15;

    block_color.rgb +=
      (vol_light_color * vol_light * vol_intensity * (1.0 - rainStrength));
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

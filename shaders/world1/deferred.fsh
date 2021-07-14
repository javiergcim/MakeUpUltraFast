#version 120
/* MakeUp - deferred.fsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;

#if AO == 1
  uniform float inv_aspect_ratio;
  uniform float fov_y_inv;
#endif

#if V_CLOUDS != 0
  uniform sampler2D noisetex;
  uniform vec3 cameraPosition;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
#endif

#if AO == 1 || V_CLOUDS != 0
  uniform mat4 gbufferProjection;
  uniform int frame_mod;
  uniform float frameTimeCounter;

  #if MC_VERSION >= 11300
    uniform sampler2D colortex5;
  #endif
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
  #include "/lib/volumetric_clouds_end.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex0, texcoord);
  float d = texture2D(depthtex0, texcoord).r;
  float linear_d = ld(d);

  #if AO == 1 || V_CLOUDS != 0
    #if AA_TYPE > 0
      float dither = shifted_dither_grad_noise(gl_FragCoord.xy);
    #else
      #if MC_VERSION >= 11300
        float dither = texture_noise_64(gl_FragCoord.xy, colortex5);
      #else
        float dither = dither_grad_noise(gl_FragCoord.xy);
      #endif
    #endif
  #endif

  #if V_CLOUDS != 0
    if (linear_d > 0.9999) {  // Only sky
      block_color = vec4(HI_DAY_COLOR, 1.0);
      vec4 world_pos =
        gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
      vec3 view_vector = normalize(world_pos.xyz);

      float bright =
        dot(view_vector, normalize(vec3(0.0, 0.89442719, 0.4472136)));
      bright = clamp((bright * 2.0) - 1.0, 0.0, 1.0);
      bright *= bright * bright * bright;

      block_color.rgb = get_end_cloud(view_vector, block_color.rgb, bright, dither);
    }
  #else
    if (linear_d > 0.9999) {  // Only sky
      block_color = vec4(HI_DAY_COLOR, 1.0);
    }
  #endif

  #if AO == 1
    // AO distance attenuation
    float ao_att = sqrt(linear_d);
    float final_ao = mix(dbao(dither), 1.0, ao_att);
    block_color *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
  #endif

  /* DRAWBUFFERS:14 */
  gl_FragData[0] = vec4(block_color.rgb, d);
  gl_FragData[1] = block_color;
}

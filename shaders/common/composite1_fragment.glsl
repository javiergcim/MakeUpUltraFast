/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform int frameCounter;
uniform mat4 gbufferProjection;

#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/dither_shift.glsl"
#include "/iris_uniforms/pixel_size_x.glsl"
#include "/iris_uniforms/pixel_size_y.glsl"
#include "/iris_uniforms/inv_aspect_ratio.glsl"
#include "/iris_uniforms/fov_y_inv.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex2;
// uniform float inv_aspect_ratio;

#ifdef DOF
  uniform float centerDepthSmooth;
  // uniform float pixel_size_x;
  // uniform float pixel_size_y;
  // uniform float viewWidth;
  // uniform float viewHeight;
  // uniform float fov_y_inv;
#endif

#ifdef DOF
  const bool colortex1MipmapEnabled = true;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/bloom.glsl"

#if defined BLOOM || defined DOF
  #include "/lib/dither.glsl"
#endif

#ifdef DOF
  #include "/lib/blur.glsl"
#endif

#ifdef BLOOM
  const bool colortex2MipmapEnabled = true;
#endif

void main() {
  // Pseudo-uniforms section
  #ifdef DOF
    float pixel_size_x = pixel_size_x();
    float pixel_size_y = pixel_size_y();
  #endif
  float inv_aspect_ratio = inv_aspect_ratio();
  #if defined BLOOM || defined DOF
    int frame_mod = frame_mod();
    float dither_shift = dither_shift(frame_mod);
  #endif
  float fov_y_inv = fov_y_inv();

  vec4 block_color = texture2D(colortex1, texcoord);

  #if defined BLOOM || defined DOF
    #if AA_TYPE > 0
      float dither = shifted_eclectic_r_dither(gl_FragCoord.xy, dither_shift);
    #else
      float dither = semiblue(gl_FragCoord.xy);
    #endif
  #endif

  #ifdef DOF
    block_color.rgb = noised_blur(
      block_color,
      colortex1,
      texcoord,
      DOF_STRENGTH,
      dither,
      pixel_size_x,
      pixel_size_y,
      fov_y_inv,
      inv_aspect_ratio
    );
  #endif

  #ifdef BLOOM
    vec3 bloom = mipmap_bloom(colortex2, texcoord, dither, inv_aspect_ratio);
    block_color.rgb += bloom;
  #endif

  /* DRAWBUFFERS:1 */
  gl_FragData[0] = block_color;
  // gl_FragData[0] = vec4(bloom, block_color.a);
}

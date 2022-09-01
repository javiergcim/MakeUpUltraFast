#if MC_VERSION < 11300
  const bool colortex0Clear = false;
  const bool colortex1Clear = false;
  const bool colortex2Clear = false;
  const bool colortex3Clear = false;
  const bool gaux1Clear = false;
  const bool gaux2Clear = false;
  const bool gaux3Clear = false;
  const bool gaux4Clear = false;
#endif

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int frameCounter;

#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/dither_shift.glsl"

// Pseudo-uniforms uniforms
uniform float viewWidth;
uniform float viewHeight;

#include "/iris_uniforms/pixel_size_x.glsl"
#include "/iris_uniforms/pixel_size_y.glsl"

// 'Global' constants from system
uniform sampler2D colortex1;


#if AA_TYPE > 0 || defined MOTION_BLUR
  uniform sampler2D colortex3;  // TAA past averages
  // uniform float pixel_size_x;
  // uniform float pixel_size_y;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferProjection;
  uniform mat4 gbufferModelViewInverse;
  uniform vec3 cameraPosition;
  uniform vec3 previousCameraPosition;
  uniform mat4 gbufferPreviousProjection;
  uniform mat4 gbufferPreviousModelView;
  uniform sampler2D depthtex0;
  uniform float frameTime;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if AA_TYPE > 0 || defined MOTION_BLUR
  #include "/lib/projection_utils.glsl"
  #include "/lib/past_projection_utils.glsl"
#endif

#ifdef MOTION_BLUR
  #include "/lib/dither.glsl"
  #include "/lib/motion_blur.glsl"
#endif

#if AA_TYPE > 0
  #include "/lib/luma.glsl"
  #include "/lib/fast_taa.glsl"
#endif

#include "/lib/tone_maps.glsl"

void main() {
  // Pseudo-uniforms section
  #if AA_TYPE > 0 || defined MOTION_BLUR
    float pixel_size_x = pixel_size_x();
    float pixel_size_y = pixel_size_y();
  #endif
  #ifdef MOTION_BLUR
    int frame_mod = frame_mod();
    float dither_shift = dither_shift(frame_mod);
  #endif

  vec4 block_color = texture2D(colortex1, texcoord);

  // Precalc past position and velocity
  #if AA_TYPE > 0 || defined MOTION_BLUR
    // Reproyección del cuadro anterior
    float z_depth = texture2D(depthtex0, texcoord).r;
    vec2 texcoord_past;
    vec3 curr_view_pos;
    vec3 curr_feet_player_pos;
    vec3 prev_feet_player_pos;
    vec3 prev_view_pos;
    vec2 final_pos;

    if (z_depth < 0.56) {
      texcoord_past = texcoord;
    } else {
      curr_view_pos = vec3(vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y) * (texcoord * 2.0 - 1.0) + gbufferProjectionInverse[3].xy, gbufferProjectionInverse[3].z);
      curr_view_pos /= (gbufferProjectionInverse[2].w * (z_depth * 2.0 - 1.0) + gbufferProjectionInverse[3].w);
      curr_feet_player_pos = mat3(gbufferModelViewInverse) * curr_view_pos + gbufferModelViewInverse[3].xyz;

      prev_feet_player_pos = z_depth > 0.56 ? curr_feet_player_pos + cameraPosition - previousCameraPosition : curr_feet_player_pos;
      prev_view_pos = mat3(gbufferPreviousModelView) * prev_feet_player_pos + gbufferPreviousModelView[3].xyz;
      final_pos = vec2(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y) * prev_view_pos.xy + gbufferPreviousProjection[3].xy;
      texcoord_past = (final_pos / -prev_view_pos.z) * 0.5 + 0.5;
    }

  #endif

  #ifdef MOTION_BLUR
    // "Velocidad"
    vec2 velocity = texcoord - texcoord_past;
    block_color.rgb = motion_blur(block_color.rgb, z_depth, velocity, colortex1, pixel_size_x, pixel_size_y, dither_shift);
  #endif

  #if AA_TYPE > 0
    #ifdef DOF
      block_color = fast_taa_depth(block_color, texcoord_past, pixel_size_x, pixel_size_y);
    #else
      block_color.rgb = fast_taa(block_color.rgb, texcoord_past, pixel_size_x, pixel_size_y);
    #endif
    /* DRAWBUFFERS:03 */
    gl_FragData[0] = block_color;  // colortex0
    gl_FragData[1] = block_color;  // To TAA averages
  #else
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;  // colortex0
  #endif
}

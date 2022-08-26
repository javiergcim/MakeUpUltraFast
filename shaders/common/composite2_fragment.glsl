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
// uniform float viewWidth;
// uniform float viewHeight;


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
varying float exposure;

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
    vec3 closest_to_camera;
    vec3 fragposition;
    vec3 previous_position;
    vec2 texcoord_past;

    if (z_depth < 0.56) {
      texcoord_past = texcoord;
    } else {
      closest_to_camera = vec3(texcoord, z_depth);
      fragposition = to_screen_space(closest_to_camera);
      fragposition = mat3(gbufferModelViewInverse) * fragposition + gbufferModelViewInverse[3].xyz + (cameraPosition - previousCameraPosition);
      previous_position = mat3(gbufferPreviousModelView) * fragposition + gbufferPreviousModelView[3].xyz;
      previous_position = to_clip_space(previous_position);
      previous_position.xy = texcoord + (previous_position.xy - closest_to_camera.xy);
      texcoord_past = previous_position.xy;  // Posición en el pasado
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
  #endif

  vec3 block_tonemaped = block_color.rgb;
  block_tonemaped *= vec3(exposure);
  
  #if defined UNKNOWN_DIM
    block_tonemaped = custom_sigmoid_alt(block_tonemaped);
  #else
    block_tonemaped = custom_sigmoid(block_tonemaped);
  #endif

  #if AA_TYPE > 0
    /* DRAWBUFFERS:03 */
    gl_FragData[0] = vec4(block_tonemaped, block_color.a);  // colortex0
    gl_FragData[1] = block_color;  // To TAA averages
  #else
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(block_tonemaped, block_color.a);  // colortex0
  #endif
}

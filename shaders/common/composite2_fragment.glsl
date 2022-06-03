// Buffers clear
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool gaux2Clear = false;
const bool gaux3Clear = false;
const bool gaux4Clear = false;

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

#if AA_TYPE > 0 || defined MOTION_BLUR
  uniform sampler2D colortex3;  // TAA past averages
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferProjection;
  uniform mat4 gbufferModelViewInverse;
  uniform vec3 cameraPosition;
  uniform vec3 previousCameraPosition;
  uniform mat4 gbufferPreviousProjection;
  uniform mat4 gbufferPreviousModelView;
  uniform int frame_mod;
  uniform sampler2D depthtex0;
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

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);

  // Precalc past position and velocity
  #if AA_TYPE > 0 || defined MOTION_BLUR
    // Reproyección del cuadro anterior
    float z_depth = texture2D(depthtex0, texcoord).r;
    vec3 closest_to_camera = vec3(texcoord, z_depth);
    vec3 fragposition = to_screen_space(closest_to_camera);
    fragposition = mat3(gbufferModelViewInverse) * fragposition + gbufferModelViewInverse[3].xyz + (cameraPosition - previousCameraPosition);
    vec3 previous_position = mat3(gbufferPreviousModelView) * fragposition + gbufferPreviousModelView[3].xyz;
    previous_position = to_clip_space(previous_position);
    previous_position.xy = texcoord + (previous_position.xy - closest_to_camera.xy);
    vec2 texcoord_past = previous_position.xy;  // Posición en el pasado

    // "Velocidad"
    vec2 velocity = texcoord - texcoord_past;
  #endif

  #ifdef MOTION_BLUR
    block_color.rgb = motion_blur(block_color.rgb, z_depth, velocity, colortex1);
  #endif

  #if AA_TYPE > 0
    #ifdef DOF
      block_color = fast_taa_depth(block_color, texcoord_past, velocity);
    #else
      block_color.rgb = fast_taa(block_color.rgb, texcoord_past, velocity);
    #endif
    /* DRAWBUFFERS:03 */
    gl_FragData[0] = block_color;  // colortex0
    gl_FragData[1] = block_color;  // To TAA averages
  #else
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;  // colortex0
  #endif
}

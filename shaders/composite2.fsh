#version 130
/* MakeUp - composite1.fsh
Render: Antialiasing and motion blur

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

#ifdef MOTION_BLUR
  #ifdef DOF
    uniform sampler2D colortex0;
  #endif
#endif

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
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
in vec2 texcoord;

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
  vec4 block_color = texture(colortex1, texcoord);

  // Precalc past position and velocity
  #if AA_TYPE > 0 || defined MOTION_BLUR
    // Reproyección del cuadro anterior
    float z_depth = block_color.a;
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
    #ifdef DOF
      block_color.rgb = motion_blur(block_color, velocity, colortex0);
    #else
      block_color.rgb = motion_blur(block_color, velocity, colortex1);
    #endif
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

#version 120
/* MakeUp Ultra Fast - final.fsh
Render: Antialiasing

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

#if AA_TYPE == 2 || MOTION_BLUR == 1
  uniform sampler2D colortex2;  // TAA past averages
  uniform sampler2D depthtex0;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform vec3 cameraPosition;
  uniform vec3 previousCameraPosition;
  uniform mat4 gbufferPreviousProjection;
  uniform mat4 gbufferPreviousModelView;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if AA_TYPE == 2 || MOTION_BLUR == 1
  #include "/lib/projection_utils.glsl"
#endif

#if MOTION_BLUR == 1
  #include "/lib/dither.glsl"
  #include "/lib/motion_blur.glsl"
#endif

#if AA_TYPE == 1
  #include "/lib/luma.glsl"
  #include "/lib/fxaa_intel.glsl"
#elif AA_TYPE == 2
  #include "/lib/luma.glsl"
  #include "/lib/fast_taa.glsl"
#endif

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);

  // Precalc past position and velocity
  #if AA_TYPE == 2 || MOTION_BLUR == 1
    // Reproyección del cuadro anterior
    float z_depth = texture2D(depthtex0, texcoord).x;
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

  #if MOTION_BLUR == 1
    block_color.rgb = motion_blur(block_color.rgb, z_depth, velocity);
  #endif

  #if AA_TYPE == 1
    block_color.rgb = fxaa311(block_color.rgb, AA);
    #if DOF == 1
      gl_FragData[3] = block_color;  // colortex3
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif

  #elif AA_TYPE == 2
    block_color.rgb = fast_taa(block_color.rgb, texcoord_past, velocity);
    gl_FragData[2] = block_color;  // To TAA averages
    #if DOF == 1
      gl_FragData[3] = block_color;  // colortex3
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif
  #else
    #if DOF == 1
      gl_FragData[3] = block_color;  // colortex3
    #else
      gl_FragData[0] = block_color;  // colortex0
    #endif

  #endif
}

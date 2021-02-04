#version 130
/* MakeUp Ultra Fast - gbuffers_skytextured.vsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/color_utils.glsl"

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;

uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#if AA_TYPE == 1
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = gl_MultiTexCoord0.xy;
  tint_color = gl_Color;

  sky_luma_correction = mix(
    ambient_exposure[current_hour_floor],
    ambient_exposure[current_hour_ceil],
    current_hour_fract
    );

  sky_luma_correction = 1.0 / ((sky_luma_correction * -3.5) + 4.5);

  gl_Position = ftransform();
  #if AA_TYPE == 1
    gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
  #endif
}

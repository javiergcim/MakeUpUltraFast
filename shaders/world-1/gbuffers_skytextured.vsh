#version 130
/* MakeUp Ultra Fast - gbuffers_skytextured.vsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

varying vec2 texcoord;
varying vec4 tint_color;

#if AA_TYPE == 1
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = gl_MultiTexCoord0.xy;
  tint_color = gl_Color;

  gl_Position = ftransform();
  #if AA_TYPE == 1
    gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
  #endif
}

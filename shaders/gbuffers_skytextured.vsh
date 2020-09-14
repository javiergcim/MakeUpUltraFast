#version 120
/* MakeUp Ultra Fast - gbuffers_skytextured.vsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

varying vec2 texcoord;
varying vec4 tint_color;

#ifdef TAA
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = gl_MultiTexCoord0.xy;
  tint_color = gl_Color;

  gl_Position = ftransform();
  #ifdef TAA
    gl_Position.xy += offsets[frame8] * gl_Position.w * texelSize;
  #endif
}

#version 130

#define THE_END

#include "/lib/config.glsl"

out vec2 texcoord;

vec2 calc_shadow_dist(in vec2 shadow_pos) {
  float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
  return shadow_pos.xy / distortion;
}

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  gl_Position.xy = calc_shadow_dist(gl_Position.xy);

  texcoord = (gl_MultiTexCoord0).xy;
}

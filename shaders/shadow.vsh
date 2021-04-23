#version 130

#include "/lib/config.glsl"

out vec2 texcoord;

attribute vec4 mc_Entity;

vec2 calc_shadow_dist(in vec2 shadow_pos) {
  float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
  return shadow_pos.xy / distortion;
}

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;


  if (mc_Entity.x == ENTITY_LOWERGRASS ||
      mc_Entity.x == ENTITY_UPPERGRASS ||
      mc_Entity.x == ENTITY_SMALLGRASS ||
      mc_Entity.x == ENTITY_SMALLENTS ||
      mc_Entity.x == ENTITY_SMALLENTS_NW)
  {
      gl_Position.z -= 0.0025;  // Corrección para sombra de follaje.
  }

  gl_Position.xy = calc_shadow_dist(gl_Position.xy);

  texcoord = (gl_MultiTexCoord0).xy;
}

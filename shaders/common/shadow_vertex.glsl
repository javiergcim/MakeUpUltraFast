#include "/lib/config.glsl"

varying vec2 texcoord;

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
      // Corrección para sombra de follaje.
      #if SHADOW_RES == 0 || SHADOW_RES == 1
        gl_Position.z -= 0.0025;
      #elif SHADOW_RES == 2 || SHADOW_RES == 3
        gl_Position.z -= 0.0025;
      #elif SHADOW_RES == 4 || SHADOW_RES == 5
        gl_Position.z -= 0.0015;
      #elif SHADOW_RES == 6 || SHADOW_RES == 7
        gl_Position.z -= 0.000;
      #endif
  }

  gl_Position.xy = calc_shadow_dist(gl_Position.xy);

  texcoord = gl_MultiTexCoord0.xy;
}

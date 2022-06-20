#include "/lib/config.glsl"

varying vec2 texcoord;

#ifdef COLORED_SHADOW
  varying float is_water;
#endif

attribute vec4 mc_Entity;

vec2 calc_shadow_dist(in vec2 shadow_pos) {
  float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
  return shadow_pos.xy / distortion;
}

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

  #ifdef COLORED_SHADOW
    is_water = 0.0;
  #endif

  if (mc_Entity.x == ENTITY_LOWERGRASS ||
      mc_Entity.x == ENTITY_UPPERGRASS ||
      mc_Entity.x == ENTITY_SMALLGRASS ||
      mc_Entity.x == ENTITY_SMALLENTS ||
      mc_Entity.x == ENTITY_SMALLENTS_NW)
  {
    // Corrección para sombra de follaje.
    #if SHADOW_RES == 0 || SHADOW_RES == 1 || SHADOW_RES == 2
      gl_Position.z -= 0.00125;
    #elif SHADOW_RES == 3 || SHADOW_RES == 4 || SHADOW_RES == 5
      gl_Position.z -= 0.00125;
    #elif SHADOW_RES == 6 || SHADOW_RES == 7 || SHADOW_RES == 8
      gl_Position.z -= 0.0003;
    #elif SHADOW_RES == 9 || SHADOW_RES == 10 || SHADOW_RES == 11
      gl_Position.z -= 0.0001;
    #endif
  }
  #ifdef COLORED_SHADOW
    else if (mc_Entity.x == ENTITY_WATER){
      is_water = 1.0;
    }
  #endif

  gl_Position.xy = calc_shadow_dist(gl_Position.xy);

  texcoord = gl_MultiTexCoord0.xy;
}

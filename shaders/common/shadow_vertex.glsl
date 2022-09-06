#include "/lib/config.glsl"

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

varying vec2 texcoord;

#ifdef COLORED_SHADOW
  varying float is_water;
#endif

attribute vec4 mc_Entity;

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

  vec4 position = shadowModelViewInverse * shadowProjectionInverse * gl_ModelViewProjectionMatrix * gl_Vertex;
  gl_Position = shadowProjection * shadowModelView * position;

  float dist = length(gl_Position.xy);
	float distortFactor = dist * SHADOW_DIST + (1.0 - SHADOW_DIST);
	
	gl_Position.xy *= 1.0 / distortFactor;
	gl_Position.z = gl_Position.z * 0.2;

  #ifdef COLORED_SHADOW
    is_water = 0.0;

    if (mc_Entity.x == ENTITY_WATER) {
      is_water = 1.0;
    }
  #endif
}

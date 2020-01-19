#version 120
/* MakeUp Ultra Fast - gbuffers_textured.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

#define ENTITY_SMALLGRASS   10031.0	//
#define ENTITY_LOWERGRASS   10175.0	// Lower half only in 1.13+
#define ENTITY_UPPERGRASS	  10176.0 // Upper half only used in 1.13+
#define ENTITY_SMALLENTS    10059.0	// sapplings(6), dandelion(37), rose(38), carrots(141), potatoes(142), beetroot(207)
#define ENTITY_VINES        10106.0
#define ENTITY_LEAVES       10018.0 // Leaves
#define ENTITY_EMISSIVE     10089.0 // Emissors like candels and others
#define ENTITY_MAGMA        10213.0 // Emissors like candels and others

// 'Global' constants from system
uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float grass;
varying float leaves;
varying float emissive;
varying float iswater;
varying float magma;

attribute vec4 mc_Entity;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  gl_FogFragCoord = length(gl_Position.xyz);

  tint_color = gl_Color;

  normal = normalize(gl_NormalMatrix * gl_Normal);

  sun_vec = normalize(sunPosition);
  moon_vec = normalize(moonPosition);

  // Grass entities
  if (
    mc_Entity.x == ENTITY_SMALLGRASS ||
    mc_Entity.x == ENTITY_LOWERGRASS ||
    mc_Entity.x == ENTITY_VINES ||
    mc_Entity.x == ENTITY_UPPERGRASS ||
    mc_Entity.x == ENTITY_SMALLENTS
  ) {
    grass = 1.0;
    leaves = 0.0;
    emissive = 0.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_LEAVES){  // Leaves
    grass = 0.0;
    leaves = 1.0;
    emissive = 0.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_EMISSIVE) { // Emissive entities
    grass = 0.0;
    leaves = 0.0;
    emissive = 1.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_MAGMA) {
    grass = 0.0;
    leaves = 0.0;
    emissive = 0.0;
    magma = 1.0;
  } else {
    grass = 0.0;
    leaves = 0.0;
    emissive = 0.0;
    magma = 0.0;
  }
}

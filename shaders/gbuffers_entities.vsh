#version 120
/* MakeUp Ultra Fast - gbuffers_entities.vsh
Render: Droped objects and similar things

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

#define ENTITY_EMISSIVE     10089.0 // Emissors like candels and others

// 'Global' constants from system
uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

// Varyings (per thread shared variables)
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float emissive;

attribute vec4 mc_Entity;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0;
  lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

  gl_FogFragCoord = length(gl_Position.xyz);

  tint_color = gl_Color;

  normal = normalize(gl_NormalMatrix * gl_Normal);

  sun_vec = normalize(sunPosition);
  moon_vec = normalize(moonPosition);

  if (mc_Entity.x == ENTITY_EMISSIVE) { // Emissive entities
    emissive = 1.0;
  } else {
    emissive = 0.0;
  }
}

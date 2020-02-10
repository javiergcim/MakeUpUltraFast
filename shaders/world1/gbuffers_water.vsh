#version 120
/* MakeUp Ultra Fast - gbuffers_water.vsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define ENTITY_WATER        10008.0
#define ENTITY_PORTAL       10090.0
#define ENTITY_STAINED      10079.0

// 'Global' constants from system
uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float iswater;
varying float istranslucent;
varying vec4 position2;
varying vec4 worldposition;
varying vec3 tangent;
varying vec3 binormal;

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

void main() {
  tint_color = gl_Color;
  texcoord = gl_MultiTexCoord0.xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  normal = normalize(gl_NormalMatrix * gl_Normal);
  vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
  position2 = gl_ModelViewMatrix * gl_Vertex;
  worldposition = position + vec4(cameraPosition.xyz, 0.0);
  gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
  tangent = normalize(gl_NormalMatrix * at_tangent.xyz );
  binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));

  gl_FogFragCoord = length(gl_Position.xyz);
  sun_vec = normalize(sunPosition);
  moon_vec = normalize(moonPosition);

  // Special entities
  iswater = 0.0;
  istranslucent = 1.0;
  if (mc_Entity.x == ENTITY_WATER) {  // Water
    iswater = 1.0;
    istranslucent = 0.0;
  } else if (mc_Entity.x == ENTITY_STAINED) {  // translucent
    iswater = 0.0;
    istranslucent = 1.0;
  } else if (mc_Entity.x == ENTITY_PORTAL) {  // Portal
    iswater = 0.0;
    istranslucent = 0.0;
  }
}

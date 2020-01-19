#version 120
/* MakeUp Ultra Fast - gbuffers_textured.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

#define ENTITY_MAGMA     10213.0 // Emissors like candels and others

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float magma;

attribute vec4 mc_Entity;

void main() {
  gl_Position = ftransform();
  texcoord = gl_MultiTexCoord0.xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  gl_FogFragCoord = length(gl_Position.xyz);

  tint_color = gl_Color;

  magma = 0.0;
  if (mc_Entity.x == ENTITY_MAGMA) { // Emissive entities
    magma = 1.0;
  }
}

#version 120
/* MakeUp Ultra Fast - deferred.vsh
Render: Used for ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if AA_TYPE == 2
  #include "/src/taa_offset.glsl"
#endif

void main() {
  gl_Position = ftransform();
  #if AA_TYPE == 2
    gl_Position.xy += offsets[frame8] * gl_Position.w * texelSize;
  #endif
  texcoord = gl_MultiTexCoord0.xy;
}

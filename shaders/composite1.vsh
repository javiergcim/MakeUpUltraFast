#version 120
/* MakeUp - composite1.fsh
Render: Bloom and DoF

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define COMPOSITE1_SHADER

#include "/common/composite1_vertex.glsl"

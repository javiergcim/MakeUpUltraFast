#version 150
/* MakeUp - composite1.fsh
Render: Antialiasing and motion blur

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define COMPOSITE2_SHADER
#define NO_SHADOWS

#include "/common/composite2_fragment.glsl"

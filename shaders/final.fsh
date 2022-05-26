#version 120
/* MakeUp - final.fsh
Render: Final renderer

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define FINAL_SHADER
#define NO_SHADOWS

#include "/common/final_fragment.glsl"

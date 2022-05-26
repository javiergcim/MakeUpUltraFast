#version 120
/* MakeUp - composite.fsh
Render: Bloom and volumetric light

Javier Garduño - GNU Lesser General Public License v3.0
*/
#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define COMPOSITE_SHADER

#include "/common/composite_fragment.glsl"
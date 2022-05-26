#version 120
/* MakeUp - gbuffers_water.vsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define WATER_F

#include "/common/water_blocks_vertex.glsl"


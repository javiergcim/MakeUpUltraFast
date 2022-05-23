#version 150
/* MakeUp - gbuffers_hand_water.vsh
Render: Translucent hand objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_HAND_WATER

#include "/common/solid_blocks_vertex.glsl"

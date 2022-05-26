#version 120
/* MakeUp - gbuffers_hand.vsh
Render: Hand opaque objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_HAND

#include "/common/solid_blocks_vertex.glsl"

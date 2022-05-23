#version 150
/* MakeUp - gbuffers_terrain.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_TERRAIN
#define FOLIAGE_V
#define EMMISIVE_V

#include "/common/solid_blocks_vertex.glsl"

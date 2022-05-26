#version 120
/* MakeUp - gbuffers_terrain.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_TERRAIN
#define FOLIAGE_V

#include "/common/solid_blocks_fragment.glsl"
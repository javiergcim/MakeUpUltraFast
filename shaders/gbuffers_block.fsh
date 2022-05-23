#version 150
/* MakeUp - gbuffers_beaconbeam.fsh
Render: Beacon beam

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_BLOCK

#include "/common/solid_blocks_fragment.glsl"

#version 150
/* MakeUp - gbuffers_hand_water.fsh
Render: Translucent hand objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_HAND_WATER
#define CLOUDS_SHADER

#include "/common/solid_blocks_fragment.glsl"
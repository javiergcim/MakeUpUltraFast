#version 130
/* MakeUp - gbuffers_clouds.vsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_CLOUDS
#define NO_SHADOWS

#include "/common/clouds_blocks_vertex.glsl"

#version 150
/* MakeUp - gbuffers_spidereyes.vsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_SPIDEREYES
#define NO_SHADOWS

#include "/common/spidereyes_blocks_vertex.glsl"

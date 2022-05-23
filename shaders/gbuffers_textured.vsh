#version 150
/* MakeUp - gbuffers_textured.vsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_TEXTURED

#include "/common/solid_blocks_vertex.glsl"

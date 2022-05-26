#version 120
/* MakeUp - gbuffers_basic.fsh
Render: Basic elements - lines

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_BASIC
#define NO_SHADOWS

#include "/common/basic_blocks_fragment.glsl"

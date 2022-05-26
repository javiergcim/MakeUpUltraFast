#version 120
/* MakeUp - gbuffers_basic.vsh
Render: Basic elements - lines

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_BASIC
#define NO_SHADOWS
#define SHADER_BASIC
#define SHADER_LINE

#include "/common/basic_blocks_vertex.glsl"

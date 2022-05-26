#version 120
/* MakeUp - gbuffers_textured.fsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_TEXTURED
#define CLOUDS_SHADER

#include "/common/solid_blocks_fragment.glsl"

#version 120
/* MakeUp - gbuffers_textured.fsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_TEXTURED
#if MC_VERSION >= 11300
  #define CLOUDS_SHADER
#endif
#define NO_SHADOWS

#include "/common/solid_blocks_fragment.glsl"

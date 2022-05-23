#version 150
/* MakeUp - gbuffers_armor_glint.vsh
Render: Glow objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_ARMOR_GLINT
#define ENTITY_GLINT
#define SHADER_BASIC

#include "/common/glint_blocks_vertex.glsl"
#version 120
/* MakeUp - gbuffers_entities_glowing.vsh
Render: Droped objects, mobs and things like that... glowing

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define GBUFFER_ENTITIES
#define GBUFFER_ENTITY_GLOW
#define CAVEENTITY_V

#include "/common/solid_blocks_vertex.glsl"

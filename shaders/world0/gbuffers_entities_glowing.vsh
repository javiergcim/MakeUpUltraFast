#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_entities_glowing.vsh
Render: Droped objects, mobs and things like that... glowing

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_ENTITIES
#define GBUFFER_ENTITY_GLOW
#define CAVEENTITY_V

#include "/common/solid_blocks_vertex.glsl"

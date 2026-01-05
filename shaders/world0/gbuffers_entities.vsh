#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_entities.vsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_ENTITIES
#define CAVEENTITY_V

#include "/common/solid_blocks_vertex.glsl"

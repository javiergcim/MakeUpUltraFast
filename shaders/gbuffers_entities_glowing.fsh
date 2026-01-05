#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_entities_glowing.fsh
Render: Droped objects, mobs and things like that... glowing

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define GBUFFER_ENTITIES
#define GBUFFER_ENTITY_GLOW

#include "/common/solid_blocks_fragment.glsl"


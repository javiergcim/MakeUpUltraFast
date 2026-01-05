#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_armor_glint.vsh
Render: Glow objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_ARMOR_GLINT
#define ENTITY_GLINT
#define SHADER_BASIC
#define NO_SHADOWS

#include "/common/glint_blocks_vertex.glsl"
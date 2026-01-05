#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_basic.vsh
Render: Basic elements - lines

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_BASIC
#define NO_SHADOWS
#define SHADER_LINE

#include "/common/basic_blocks_vertex.glsl"

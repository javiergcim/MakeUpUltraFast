#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_line.vsh
Render: Render lines

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define GBUFFER_LINE
#define NO_SHADOWS
#define SHADER_BASIC
#define SHADER_LINE

#include "/common/line_blocks_vertex.glsl"

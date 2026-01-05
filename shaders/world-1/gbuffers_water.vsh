#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_water.vsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define WATER_F
#define NO_SHADOWS

#include "/common/water_blocks_vertex.glsl"


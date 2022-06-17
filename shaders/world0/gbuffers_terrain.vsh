#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_terrain.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_TERRAIN
#define FOLIAGE_V
#define EMMISIVE_V

#include "/common/solid_blocks_vertex.glsl"

#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_hand_water.vsh
Render: Translucent hand objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_HAND_WATER

#include "/common/solid_blocks_vertex.glsl"

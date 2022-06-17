#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_hand.vsh
Render: Hand opaque objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_HAND

#include "/common/solid_blocks_vertex.glsl"

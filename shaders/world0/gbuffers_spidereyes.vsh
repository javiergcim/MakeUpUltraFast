#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_spidereyes.vsh
Render: Some creatures eyes (like spider)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_SPIDEREYES
#define NO_SHADOWS

#include "/common/spidereyes_blocks_vertex.glsl"

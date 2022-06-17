#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_clouds.vsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_CLOUDS
#define NO_SHADOWS

#include "/common/clouds_blocks_vertex.glsl"

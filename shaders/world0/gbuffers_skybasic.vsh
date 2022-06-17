#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_skybasic.vsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_SKYBASIC
#define NO_SHADOWS

#include "/common/skybasic_vertex.glsl"

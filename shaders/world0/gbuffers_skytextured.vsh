#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_skytextured.vsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_SKYTEXTURED
#define NO_SHADOWS

#include "/common/skytextured_vertex.glsl"

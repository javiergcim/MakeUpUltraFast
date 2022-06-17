#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - deferred.vsh
Render: Ambient occlusion, volumetric clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define DEFERRED_SHADER

#include "/common/deferred_vertex.glsl"

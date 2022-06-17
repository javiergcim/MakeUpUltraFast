#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_SKYBASIC
#define NO_SHADOWS
#define SET_FOG_COLOR

#include "/common/skybasic_fragment.glsl"

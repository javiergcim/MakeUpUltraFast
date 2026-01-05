#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_CLOUDS
#define NO_SHADOWS

#include "/common/clouds_blocks_fragment.glsl"
#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_CLOUDS
#define NO_SHADOWS
#define PARTICLE_SHADER

#include "/common/clouds_blocks_fragment.glsl"
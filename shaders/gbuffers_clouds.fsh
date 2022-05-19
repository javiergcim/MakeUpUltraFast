#version 130
/* MakeUp - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define UNKNOWN_DIM
#define GBUFFER_CLOUDS
#define NO_SHADOWS
#define CLOUDS_SHADER

#include "/common/clouds_blocks_fragment.glsl"
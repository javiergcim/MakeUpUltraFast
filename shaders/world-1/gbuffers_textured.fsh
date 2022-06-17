#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_textured.fsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_TEXTURED
#define PARTICLE_SHADER
#define NO_SHADOWS

#include "/common/solid_blocks_fragment.glsl"

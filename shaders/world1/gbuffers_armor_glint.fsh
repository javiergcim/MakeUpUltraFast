#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_armor_glint.fsh
Render: Glow objects

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define GBUFFER_ARMOR_GLINT
#define SHADER_BASIC

#include "/common/glint_blocks_fragment.glsl"

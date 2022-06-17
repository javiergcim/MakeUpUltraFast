#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - gbuffers_line.vsh
Render: Render lines

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define GBUFFER_LINE

#include "/common/line_blocks_fragment.glsl"

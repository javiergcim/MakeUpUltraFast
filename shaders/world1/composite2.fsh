#version 120
#extension GL_EXT_gpu_shader4 : enable
/* MakeUp - composite1.fsh
Render: Antialiasing and motion blur

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define COMPOSITE2_SHADER
#define NO_SHADOWS

#include "/common/composite2_fragment.glsl"

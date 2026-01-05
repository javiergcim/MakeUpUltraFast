#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define GBUFFER_SKYBASIC
#define NO_SHADOWS

#include "/common/skybasic_fragment.glsl"

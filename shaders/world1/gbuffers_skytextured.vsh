#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - gbuffers_skytextured.vsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define GBUFFER_SKYTEXTURED
#define NO_SHADOWS

#include "/common/skytextured_vertex.glsl"

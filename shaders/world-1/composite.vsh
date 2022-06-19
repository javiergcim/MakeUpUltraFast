#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - composite.fsh
Render: Bloom and volumetric light

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define COMPOSITE_SHADER
#define NO_SHADOWS

#include "/common/composite_vertex.glsl"

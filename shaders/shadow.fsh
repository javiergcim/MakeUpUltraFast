#version 120
#extension GL_ARB_shader_texture_lod : enable
/* MakeUp - shadow.fsh
Render: Shadowmap

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define SHADOW_SHADER

#include "/common/shadow_fragment.glsl"

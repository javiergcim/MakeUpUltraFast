#version 120
/* MakeUp - shadow.fsh
Render: Shadowmap

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
    #define UNKNOWN_DIM
#endif
#define SHADOW_SHADER

#include "/common/shadow_vertex.glsl"

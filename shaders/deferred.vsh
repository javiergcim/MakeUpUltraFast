#version 150
/* MakeUp - deferred.vsh
Render: Ambient occlusion, volumetric clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define DEFERRED_SHADER

#include "/common/deferred_vertex.glsl"

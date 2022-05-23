#version 150
/* MakeUp - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_SKYTEXTURED
#define NO_SHADOWS

#include "/common/skytextured_fragment.glsl"

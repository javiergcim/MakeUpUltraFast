#version 120
/* MakeUp - gbuffers_damagedblock.fsh
Render: Damaged block effect

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define NO_SHADOWS
#define GBUFFER_DAMAGE

#include "/common/damage_fragment.glsl"
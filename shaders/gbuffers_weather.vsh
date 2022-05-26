#version 120
/* MakeUp - gbuffers_weather.vsh
Render: Weather

Javier Garduño - GNU Lesser General Public License v3.0
*/

#ifdef USE_BASIC_SH
  #define UNKNOWN_DIM
#endif
#define GBUFFER_WEATHER

#include "/common/solid_blocks_vertex.glsl"
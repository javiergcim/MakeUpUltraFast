#version 120
/* MakeUp - gbuffers_weather.fsh
Render: Weather

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_WEATHER
#if MC_VERSION >= 11300
  #define CLOUDS_SHADER
#define NO_SHADOWS

#include "/common/solid_blocks_fragment.glsl"
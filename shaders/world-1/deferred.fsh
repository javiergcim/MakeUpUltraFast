#version 120
/* MakeUp - deferred.fsh
Render: Ambient occlusion, volumetric clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define DEFERRED_SHADER
#define NO_SHADOWS
#define NO_CLOUDY_SKY

#include "/common/deferred_fragment.glsl"

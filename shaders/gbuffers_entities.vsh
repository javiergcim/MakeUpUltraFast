#version 120
/* MakeUp Ultra Fast - gbuffers_entities.vsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define ENTITY_V
#define CAVEENTITY_V

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float light_mix;
uniform float far;
uniform sampler2D texture;
uniform float nightVision;
uniform float rainStrength;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;

#if AA_TYPE == 2
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  #include "/src/light_vertex.glsl"
  #include "/src/fog_vertex.glsl"
}

#version 120
/* MakeUp Ultra Fast - gbuffers_terrain.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define FOLIAGE_V
#define EMMISIVE_V

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

#include "/lib/shadow_utils.glsl"

const bool generateShadowMipmap = true;
const int shadowMapResolution = 1024;
const float shadowDistance = 15.0f;

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

uniform vec3 lightvec;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 gbufferProjectionInverse;

#if WAVING == 1
  uniform vec3 cameraPosition;
  uniform mat4 gbufferModelView;
  uniform mat4 gbufferModelViewInverse;
  uniform float frameTimeCounter;
  uniform float wetness;
  uniform sampler2D noisetex;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;

varying vec3 spos;

attribute vec4 mc_Entity;

#if AA_TYPE == 2
  #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if WAVING == 1
  attribute vec2 mc_midTexCoord;
  #include "/lib/vector_utils.glsl"
#endif

#define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
#define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
#define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

#define transMAD(mat, v) (mat3x3(mat) * (v) + (mat)[3].xyz)
#define projMAD3(mat, v) (diagonal3(mat) * (v) + (mat)[3].xyz)

vec3 getShadowCoordinate(vec3 vpos, float bias) {
	vec3 position	= vpos;
	position = transMAD(gbufferModelViewInverse, position);
	position += vec3(bias) * lightvec;
	position = transMAD(shadowModelView, position);
	position = projMAD3(shadowProjection, position);
	position.z -= 0.0007;

	position.z *= 0.2;
	warpShadowmap(position.xy);

	return position * 0.5 + 0.5;
}




void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"

  // Special entities
  float emissive;
  float magma;
  if (mc_Entity.x == ENTITY_EMISSIVE) { // Emissive entities
    emissive = 1.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_MAGMA) {
    emissive = 0.0;
    magma = 1.0;
  } else {
    emissive = 0.0;
    magma = 0.0;
  }

  #include "/src/light_vertex.glsl"
  #include "/src/fog_vertex.glsl"

	vec4 temp_position = gl_Vertex;
	temp_position = transMAD(gl_ModelViewMatrix, temp_position.xyz).xyzz;
	// vpos = position.xyz;

	spos = getShadowCoordinate(temp_position.xyz, 0.08 * (2048.0 / shadowMapResolution));
}

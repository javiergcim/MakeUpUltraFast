#version 120
/* MakeUp Ultra Fast - gbuffers_skytextured.fsh
Render: sun, moon

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils_end.glsl"

// uniform sampler2D texture;

#if V_CLOUDS != 0
  uniform sampler2D depthtex0;
  uniform sampler2D gaux3;
  uniform vec3 cameraPosition;
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 gbufferProjection;
  uniform float frameTimeCounter;

	uniform float viewWidth;
	uniform float viewHeight;
	uniform float rainStrength;
#endif

varying vec2 texcoord;
varying vec4 tint_color;

#if V_CLOUDS != 0
  #include "/lib/luma.glsl"
  #include "/lib/dither.glsl"
#endif

#if V_CLOUDS != 0
  #include "/lib/projection_utils.glsl"
  #include "/lib/volumetric_clouds_end.glsl"
#endif

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(HI_DAY_COLOR, 1.0);

  #if V_CLOUDS != 0
    vec4 screen_pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
		vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

		vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
		vec3 view_vector = normalize(world_pos.xyz);

    block_color.rgb = get_end_cloud(view_vector, block_color.rgb);
  #endif

  #include "/src/writebuffers.glsl"
}

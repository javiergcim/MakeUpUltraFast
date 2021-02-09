#version 130
/* MakeUp Ultra Fast - composite.fsh
Render: Ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;

#if AO == 1
  uniform sampler2D colortex5;
  uniform float inv_aspect_ratio;
  uniform mat4 gbufferProjection;
  uniform float frameTimeCounter;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if AO == 1
  varying float fov_y_inv;
#endif

#include "/lib/color_utils_end.glsl"
#include "/lib/depth.glsl"

#if AO == 1
  #include "/lib/dither.glsl"
  #include "/lib/ao.glsl"
#endif

void main() {
  vec4 block_color = texture(colortex0, texcoord);
  float d = texture(depthtex0, texcoord).r;
  float linear_d = ld(d);

  if (blindness > .01) {
    block_color.rgb =
      mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  #if AO == 1
    // AO distance attenuation
    float ao_att = sqrt(linear_d);
    float final_ao = mix(dbao(), 1.0, ao_att);
    block_color *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
  #endif

  /* DRAWBUFFERS:04 */
	gl_FragData[0] = vec4(block_color.rgb, d);
	gl_FragData[1] = block_color;
	gl_FragData[4] = block_color;
}

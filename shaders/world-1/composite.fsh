#version 120
/* MakeUp - composite.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D colortex1;
uniform float far;
uniform float near;
uniform float blindness;
uniform int isEyeInWater;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#ifdef BLOOM
  varying float exposure;  // Flat
#endif

#ifdef BLOOM
  #include "/lib/luma.glsl"
#endif

#include "/lib/depth.glsl"

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);
  float d = block_color.a;
  float linear_d = ld(d);

  if (blindness > .01) {
    block_color.rgb =
    mix(block_color.rgb, vec3(0.0), blindness * linear_d * far * .12);
  }

  // Dentro de la nieve
  #ifdef BLOOM
    if (isEyeInWater == 3) {
      block_color.rgb = mix(
        block_color.rgb,
        vec3(0.7, 0.8, 1.0) / exposure,
        clamp(screen_distance * .5, 0.0, 1.0)
      );
    }
  #else
  if (isEyeInWater == 3) {
    block_color.rgb = mix(
      block_color.rgb,
      vec3(0.85, 0.9, 0.6),
      clamp(screen_distance * .5, 0.0, 1.0)
    );
  }
  #endif

  #ifdef BLOOM
    // Bloom source
    float bloom_luma =
      smoothstep(0.85, 0.97, luma(block_color.rgb * exposure)) * 0.4;

    /* DRAWBUFFERS:12 */
    gl_FragData[0] = block_color;
    gl_FragData[1] = block_color * bloom_luma;
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

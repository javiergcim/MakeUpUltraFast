#version 130
/* MakeUp - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;

// Varyings (per thread shared variables)
flat in vec3 up_vec;
in vec4 star_data;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(star_data.rgb, 1.0);

  if (star_data.a < .9) {
    if (isEyeInWater == 0) {
      vec4 fragpos = gbufferProjectionInverse * (vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
      vec3 nfragpos = normalize(fragpos.xyz);
      float n_u = clamp(dot(nfragpos, up_vec), 0.0, 1.0);
      block_color.rgb = mix(fogColor, skyColor * .9, clamp((n_u * 4.0) - .25, 0.0, 1.0));
    } else {
      block_color.rgb = skyColor * .9;
    }
  }

  #include "/src/writebuffers.glsl"
}

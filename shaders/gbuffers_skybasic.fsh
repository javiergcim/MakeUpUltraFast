#version 120
/* MakeUp Ultra Fast - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NICE_WATER 1  // [0 1] Turn on for reflection and refraction capabilities.

// Varyings (per thread shared variables)
varying vec3 up_vec;
varying vec4 star_data;
varying vec4 tint_color;

// 'Global' constants from system
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;

void main() {
  vec3 sky_color = tint_color.rgb;
  if (star_data.a < .9) {
    if (isEyeInWater == 0) {
      vec4 fragpos = gbufferProjectionInverse * (vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
      vec3 nfragpos = normalize(fragpos.xyz);
      float n_u = clamp(dot(nfragpos, up_vec), 0.0, 1.0);
      sky_color = mix(fogColor, skyColor * .80, clamp((n_u * 4.0) - .25, 0.0, 1.0));
    } else {
      sky_color = vec3(.1, .2, .3);
    }
  }

  gl_FragData[0] = vec4(sky_color, 0.5);
  #if NICE_WATER == 1
    gl_FragData[5] = vec4(sky_color, 0.5);
  #else
    gl_FragData[1] = vec4(0.0);
  #endif
}

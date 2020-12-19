#version 120
/* MakeUp Ultra Fast - gbuffers_skybasic.fsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec3 up_vec;
varying vec4 star_data;

// 'Global' constants from system
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float frameTimeCounter;

#include "/lib/dither.glsl"

void main() {
  // Toma el color puro del bloque
  vec4 block_color = vec4(star_data.rgb, 1.0);

  if (star_data.a < .9) {
    float dither = hash12(gl_FragCoord.xy);
    dither = (dither - .5) * 0.0625;

    if (isEyeInWater == 0) {
      vec4 fragpos = gbufferProjectionInverse *
      (
        vec4(
          gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
          gl_FragCoord.z,
          1.0
        ) * 2.0 - 1.0
      );
      vec3 nfragpos = normalize(fragpos.xyz);
      // float n_u = clamp(dot(nfragpos, up_vec), 0.0, 1.0);
      float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
      // block_color.rgb = mix(fogColor, skyColor * .9, clamp((n_u * 4.0) - .25, 0.0, 1.0));
      block_color.rgb = mix(
        // vec3(0.61176471, 0.87058824, 1.0),
        // vec3(0.21568627, 0.42352941, 1.0),

        // vec3(1.        , 0.50588235, 0.21960784),
        // vec3(0.21568627, 0.42352941, 1.0),

        vec3(0.01078431, 0.02117647, 0.05),
        vec3(0.00215686, 0.00423529, 0.01),

        pow(n_u, .75)
        );
    } else {
      block_color.rgb = skyColor * .9;
    }
  }

  #include "/src/writebuffers.glsl"
}

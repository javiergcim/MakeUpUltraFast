#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int worldTime;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils.glsl"
#include "/lib/tone_maps.glsl"

void main() {
  // x: Block, y: Sky ---
  float ambient_bright = eyeBrightnessSmooth.y / 240.0;
  float candle_bright = eyeBrightnessSmooth.x / 240.0;
  candle_bright *= .1;

  float current_hour = worldTime / 1000.0;
  float exposure_coef =
    mix(
      ambient_exposure[int(floor(current_hour))],
      ambient_exposure[int(ceil(current_hour))],
      fract(current_hour)
    );

  float exposure = (ambient_bright * exposure_coef) + candle_bright;

  // Map from 1.0 - 0.0 to 1.0 - 2.5
  exposure = (exposure * -1.5) + 2.5;

  vec3 color = texture2D(colortex0, texcoord).rgb;

  color *= exposure;
  color = tonemap(color);

  gl_FragData[0] = vec4(color, 1.0);
  gl_FragData[1] = vec4(0.0);  // ¿Performance?
}

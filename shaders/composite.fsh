#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define DOF 1  // [0 1] Enables depth of field
#define DOF_STRENGTH 2  // [2 3 4 5 6 7 8 9 10 11 12 13 14]  Depth of field streght

#include "/lib/globals.glsl"

// 'Global' constants from system
uniform sampler2D G_COLOR;
uniform ivec2 eyeBrightnessSmooth;
uniform int worldTime;

#if DOF == 1
  uniform sampler2D depthtex0;
  uniform mat4 gbufferProjectionInverse;
  uniform float centerDepthSmooth;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  varying float dof_dist;
#endif

#include "/lib/color_utils.glsl"
#include "/lib/tone_maps.glsl"

#if DOF == 1
  #include "/lib/blur.glsl"
#endif

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

  vec3 color = texture2D(G_COLOR, texcoord).rgb;

  color *= exposure;
  color = tonemap(color);

  #if DOF == 1
    vec3 pos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
    vec4 vec = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
  	pos = vec.xyz / vec.w;
    float dist = length(pos);
    float blur_radius = min(abs(dist - dof_dist) / dof_dist, 1.0) * DOF_STRENGTH;
    blur_radius *= 0.00390625; // blur_radius /= 256.0;
  #endif

  gl_FragData[0] = vec4(color, 1.0);

  #if DOF == 1
    gl_FragData[4] = vec4(blur_radius);  //gaux1
  #else
    gl_FragData[1] = vec4(0.0);  // ¿Performance?
  #endif
}

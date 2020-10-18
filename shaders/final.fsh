#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Vertical blur pass and final renderer

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// Do not remove comments. It works!
/*

colortex0 - Main color canvas
colortex1 - Antialiasing auxiliar
colortex2 - TAA Averages history
colortex3 - Blur Auxiliar
gaux1 - Reflection texture
colortex5 - Blue noise texture
colortex6 - Not used
colortex7 - Not used

const int colortex0Format = R11F_G11F_B10F;

const int colortex1Format = R11F_G11F_B10F;
const int colortex2Format = R11F_G11F_B10F;
const int colortex3Format = RGBA16F;
const int gaux1Format = RGB8;
const int colortex5Format = R8;
const int colortex6Format = R8;
*/

// 'Global' constants from system
uniform sampler2D colortex0;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#if DOF == 1
  uniform sampler2D colortex3;
  uniform float pixel_size_y;
  uniform float viewHeight;
  uniform float pixel_size_x;
  uniform float viewWeight;
  uniform float aspectRatio;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"

#if DOF == 1
  #include "/lib/blur.glsl"
#endif

void main() {

  #if DOF == 1
    vec4 color_blur = texture2D(colortex3, texcoord);
    float blur_radius = color_blur.a * aspectRatio;
    vec3 color = color_blur.rgb;

    if (blur_radius > pixel_size_y) {
      float radius_inv = 1.0 / blur_radius;
      float weight;
      vec4 new_blur;

      vec4 average = vec4(0.0);
      float start  = max(texcoord.y - blur_radius, pixel_size_y * 0.5);
      float finish = min(texcoord.y + blur_radius, 1.0 - pixel_size_y * 0.5);
      float step = pixel_size_y;
      if (blur_radius > (6.0 * pixel_size_y)) {
        step *= 3.0;
      } else if (blur_radius > (2.0 * pixel_size_y)) {
        step *= 2.0;
      }

      for (float y = start; y <= finish; y += step) {  // Blur samples
        weight = fogify((y - texcoord.y) * radius_inv, 0.35);
        new_blur = texture2D(colortex3, vec2(texcoord.x, y));
        average.rgb += new_blur.rgb * weight;
        average.a += weight;
      }
      color = average.rgb / average.a;
    }

  #else
    vec3 color = texture2D(colortex0, texcoord).rgb;
  #endif

  // Tonemaping ---
  // x: Block, y: Sky ---
  float candle_bright = (eyeBrightnessSmooth.x / 240.0) * .1;
  float exposure_coef =
    mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    );
  float exposure =
    ((eyeBrightnessSmooth.y / 240.0) * exposure_coef) + candle_bright;

  // Map from 1.0 - 0.0 to 1.0 - 3.0
  exposure = (exposure * -2.0) + 3.0;

  color *= exposure;
  color = custom_lottes_tonemap(color, exposure * 1.3);  // 1.3 max lightforce

  #if CROSSP == 1
    color = crossprocess(color);
  #endif

  gl_FragColor = vec4(color, 1.0);
}

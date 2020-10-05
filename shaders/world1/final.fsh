#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Vertical blur pass and final renderer

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// Do not remove comments. It works!
/*

colortex0 - Main color canvas
colortex1 - Not used
colortex2 - Antialiasing auxiliar
colortex3 - TAA Averages history
colortex4 - Blur Auxiliar
gaux2 (colortex5) - Reflection texture ( I can't use 'colortex5' as a name or reflections break. I don't know why)
colortex6 - Not used
colortex7 - Not used

const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = R8;
const int colortex2Format = RGB8;
const int colortex3Format = R11F_G11F_B10F;
const int colortex4Format = RGBA16F;
const int colortex5Format = RGB8;
const int colortex6Format = RGBA16;
const int colortex7Format = R8;
*/

// Redefined constants
const int noiseTextureResolution = 128;
const float ambientOcclusionLevel = 1.0f;
const float eyeBrightnessHalflife = 10.0f;
const float centerDepthHalflife = 2.0f;
const float wetnessHalflife = 20.0f;
const float drynessHalflife = 10.0f;

// 'Global' constants from system
uniform sampler2D colortex0;

#if DOF == 1
  uniform sampler2D colortex4;
  uniform float pixelSizeY;
  uniform float viewHeight;
  uniform float pixelSizeX;
  uniform float viewWeight;
  uniform float aspectRatio;
  uniform float inv_aspect_ratio;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  #include "/lib/blur.glsl"
#endif

void main() {

  #if DOF == 1
    vec4 color_blur = texture2D(colortex4, texcoord);
    float blur_radius = color_blur.a;
    vec3 color = color_blur.rgb;
    float v_blur_radius = blur_radius * 0.003 * aspectRatio;

    if (v_blur_radius > pixelSizeY) {
      float radius_inv = 1.0 / blur_radius;
      float weight;
      vec4 new_blur;

      vec4 average = vec4(0.0);
      float start  = max(texcoord.y - v_blur_radius, pixelSizeY * 0.5);
      float finish = min(texcoord.y + v_blur_radius, 1.0 - pixelSizeY * 0.5);
      float step = pixelSizeY;
      if (v_blur_radius > (6.0 * pixelSizeY)) {
        step *= 3.0;
      } else if (v_blur_radius > (2.0 * pixelSizeY)) {
        step *= 2.0;
      }

      for (float y = start; y <= finish; y += step) {  // Blur samples
        weight = fogify((y - texcoord.y) * 300.0 * inv_aspect_ratio * radius_inv, 0.35);
        new_blur = texture2D(colortex4, vec2(texcoord.x, y));
        average.rgb += new_blur.rgb * weight;
        average.a += weight;
      }
      color = average.rgb / average.a;
    }

    gl_FragColor = vec4(color, 1.0);

  #else
    gl_FragColor = texture2D(colortex0, texcoord);
  #endif
}

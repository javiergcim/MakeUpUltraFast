/* Exits */
out vec4 outColor0;

/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

// Do not remove comments. It works!
/*

colortex0 - Main color canvas
colortex1 - Antialiasing auxiliar
colortex2 - Bloom auxiliar
colortex3 - TAA Averages history
gaux1 - Screen-Space-Reflection texture
gaux2 - Blue noise texture
gaux3 - Not used
gaux4 - Fog auxiliar

const int noisetexFormat = RGB8;
const int colortex0Format = RGBA16F;
*/
#ifdef DOF
/*
const int colortex1Format = RGBA16F;
*/
#else
/*
const int colortex1Format = RGBA16F;
*/
#endif
#ifdef BLOOM
/*
const int colortex2Format = RGBA16F;
*/
#else
/*
const int colortex2Format = R8;
*/
#endif
#ifdef DOF
/*
const int colortex3Format = RGBA16F;
*/
#else
/*
const int colortex3Format = RGB16F;
*/
#endif
/*
const int gaux1Format = R11F_G11F_B10F;
const int gaux2Format = R8;
const int gaux3Format = R8;
const int gaux4Format = R11F_G11F_B10F;
*/

// Buffers clear
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool gaux2Clear = false;
const bool gaux3Clear = false;
const bool gaux4Clear = false;

// 'Global' constants from system
uniform sampler2D colortex0;
// uniform ivec2 eyeBrightnessSmooth;
// uniform int current_hour_floor;
// uniform int current_hour_ceil;
// uniform float current_hour_fract;

#ifdef DEBUG_MODE
  uniform sampler2D shadowtex1;
  uniform sampler2D shadowcolor0;
  uniform sampler2D colortex3;
#endif

// Varyings (per thread shared variables)
in vec2 texcoord;
flat in float exposure;

#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"
// #include "/lib/luma.glsl"

#if CHROMA_ABER == 1
  #include "/lib/aberration.glsl"
#endif

void main() {
  #if CHROMA_ABER == 1
    vec3 block_color = color_aberration();
  #else
    vec3 block_color = texture(colortex0, texcoord).rgb;
  #endif

  block_color *= vec3(exposure);
  // block_color = lottes_tonemap(block_color, exposure + 0.6);
  block_color = custom_ACES(block_color);

  // TEST
  // Saturation
  // float actual_luma = luma(block_color);
  // block_color = mix(vec3(actual_luma), block_color, 1.5);

  #ifdef DEBUG_MODE
    // vec3 block_color;
    if (texcoord.x < 0.5 && texcoord.y < 0.5) {
      // block_color = texture(shadowtex1, texcoord * 2.0).rrr;
      block_color = vec3(exposure / 4.0);
    } else if (texcoord.x >= 0.5 && texcoord.y >= 0.5) {
      // block_color = texture(shadowcolor0, ((texcoord - vec2(0.5)) * 2.0)).aaa;
      block_color = vec3(eye_bright_smooth.y / 240.0);
    } else if (texcoord.x < 0.5 && texcoord.y >= 0.5) {
      block_color = texture(colortex0, ((texcoord - vec2(0.0, 0.5)) * 2.0)).rgb * vec3(exposure);
      block_color = custom_ACES(block_color);
    } else if (texcoord.x >= 0.5 && texcoord.y < 0.5) {
      // block_color = texture(shadowcolor0, ((texcoord - vec2(0.5, 0.0)) * 2.0)).rgb;
      block_color = vec3(eye_bright_smooth.x / 240.0);
    } else {
      block_color = vec3(0.5);
    }

    outColor0 = vec4(block_color, 1.0);

  #else
    outColor0 = vec4(block_color, 1.0);
  #endif
}

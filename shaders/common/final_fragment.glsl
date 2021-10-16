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
const int colortex0Format = R11F_G11F_B10F;
*/
#ifdef DOF
/*
const int colortex1Format = RGBA16F;
*/
#else
/*
const int colortex1Format = R11F_G11F_B10F;
*/
#endif
#ifdef BLOOM
/*
const int colortex2Format = R11F_G11F_B10F;
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
const int gaux1Format = RGB8;
const int gaux2Format = R8;
const int gaux3Format = R8;
const int gaux4Format = RGB8;
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

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying float exposure;

#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"

#if CHROMA_ABER == 1
  #include "/lib/aberration.glsl"
#endif

void main() {
  #if CHROMA_ABER == 1
    vec3 block_color = color_aberration();
  #else
    vec3 block_color = texture2D(colortex0, texcoord).rgb;
  #endif

  block_color *= exposure;
  block_color = lottes_tonemap(block_color, exposure + 0.6);

  gl_FragColor = vec4(block_color, 1.0);
}

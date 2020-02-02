#version 120
/* MakeUp Ultra Fast - final.fsh
Render: (last renderer)

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define AA 4 // [0 4 6 12] Set antialiasing quality

#include "/lib/globals.glsl"

// Buffer formats
const int R11F_G11F_B10F = 0;
// const int RGB10_A2 = 1;
// const int RGBA16 = 2;
const int RGB16 = 3;
const int RGB8 = 4;
const int R8 = 5;

const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RGB8;
const int colortex2Format = RGB8;
const int colortex3Format = RGB8;
const int gaux1Format = R8;
const int gaux2Format = RGB8;
const int gaux3Format = R8;
const int gaux4Format = R8;

// const int colortex1Format = RGB16;
// const int colortex2Format = RGB16;
// const int colortex3Format = RGB16;
// const int gaux1Format = RGB16;
// const int gaux2Format = RGB16;
// const int gaux3Format = RGB16;
// const int gaux4Format = RGB16;

// Redefined constants
const int noiseTextureResolution = 128;
const float ambientOcclusionLevel = 1.0f;
const float eyeBrightnessHalflife = 10.0f;

// 'Global' constants from system
uniform sampler2D G_COLOR;
uniform float viewWidth;
uniform float viewHeight;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/luma.glsl"
#include "/lib/fxaa_intel.glsl"

void main() {
  #if AA != 0
    vec3 color = fxaa311(texture2D(G_COLOR, texcoord).rgb, AA);
    gl_FragColor = vec4(color, 1.0);
  #else
    gl_FragColor = texture2D(G_COLOR, texcoord);
  #endif
}

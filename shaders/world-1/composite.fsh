#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define AA 4 // [0 4 6 12] Set antialiasing quality
#define TONEMAP 0 // [0 1 2] Set tonemap
#define CROSS 0 // [0 1] Activate color crossprocess

#include "/lib/globals.glsl"

// 'Global' constants from system
uniform sampler2D G_COLOR;
uniform ivec2 eyeBrightnessSmooth;
uniform float aspectRatio;
uniform float viewWidth;
uniform float viewHeight;
uniform int worldTime;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/color_utils_nether.glsl"
#include "/lib/fxaa_intel.glsl"
#include "/lib/tone_maps.glsl"

void main() {
  // x: Block, y: Sky ---
	float candle_bright = eyeBrightnessSmooth.x / 240.0;
	candle_bright *= .1;

	// float current_hour = worldTime / 1000.0;
  float exposure_coef = ambient_exposure;

	float exposure = candle_bright;

	// exposure = 3.765;
  exposure = 1.0;

	vec3 color = texture2D(G_COLOR, texcoord).rgb;

	#if AA != 0
		color = fxaa311(color, AA);
	#endif

	color *= exposure;

  #if TONEMAP == 0
    color = BSL_like(color);
  #elif TONEMAP == 1
    color = uncharted2(color);
  #elif TONEMAP == 2
    color = tonemapFilmic(color);
  #endif

  gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(0.0); // ¿Performance?
}

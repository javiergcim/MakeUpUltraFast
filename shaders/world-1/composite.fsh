#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define AA 4 // [0 4 6 12] Set antialiasing quality
#define TONEMAP 0 // [0 1] Set tonemap

#include "/lib/globals.glsl"

#define TonemapWhiteCurve 3.0 // [1.0 1.5 2.0 2.5 3.0 3.5 4.0] Tone map white curve
#define TonemapLowerCurve 1.0 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5] Tone map lower curve
#define TonemapUpperCurve 1.0 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5] Tone map upper curve

// 'Global' constants from system
uniform sampler2D G_COLOR;
uniform ivec2 eyeBrightnessSmooth;
uniform float aspectRatio;
uniform float viewWidth;
uniform float viewHeight;
uniform int worldTime;

// Varyings (per thread shared variables)
varying vec4 texcoord;

#include "/lib/color_utils_nether.glsl"
#include "/lib/fxaa_intel.glsl"
#include "/lib/tone_maps.glsl"

void main() {
  // x: Block, y: Sky ---
	// float ambient_bright = eyeBrightnessSmooth.y / 240.0;
	float candle_bright = eyeBrightnessSmooth.x / 240.0;
	candle_bright *= .1;

	// float current_hour = worldTime / 1000.0;
  float exposure_coef = ambient_exposure;

	float exposure = candle_bright;

	exposure = 4.0;

	vec3 color = texture2D(G_COLOR, texcoord.xy).rgb;

	#if AA != 0
		color = fxaa311(color, AA);
	#endif
	color *= exposure;

	#if TONEMAP == 0
		color = BSL_like(color);
	#elif TONEMAP == 1
		color = uncharted2(color);
	#endif

  gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(0.0);
}

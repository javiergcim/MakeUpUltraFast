/* MakeUp Ultra Fast - color_utils_nether.glsl
Usefull functions for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float ambient_multiplier = 1.4;

// Ambient colors per hour
vec3 ambient_baselight = vec3(1.0, 0.9176470588235294, 0.5058823529411764);

// Ambient color luma per hour in exposure calculation
float ambient_exposure = 1.0;

// How many sky_color vs. fog_color is used for fog.
float fog_color_mix = 0.0;

// Fog intesity per hour
float fog_density = 1.0;

// vec3 candle_baselight = vec3(.5, 0.4235294117647059, 0.2725490196078431);
vec3 candle_baselight = vec3(.5, 0.38823529411764707, 0.1803921568627451);
vec3 waterfog_baselight = vec3(0.09215686274509804, 0.23137254901960785, 0.3980392156862745);

float luma(vec3 color) {
	/* Calcula la luma del color dado.

	Args:
		color (vec3). El color a calcular el luma.

	Returns:
		float: La luma del color dado.

		*/
	return dot(color, vec3(0.299, 0.587, 0.114));
}

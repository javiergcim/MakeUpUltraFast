/* MakeUp Ultra Fast - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;

#define AMBIENT_MIDDLE_COLOR vec3(0.06205, 0.04998, 0.06205)
#define AMBIENT_DAY_COLOR vec3(0.06205, 0.04998, 0.06205)
#define AMBIENT_NIGHT_COLOR vec3(0.06205, 0.04998, 0.06205)

#define HI_MIDDLE_COLOR vec3(0.0465375, 0.037485, 0.0465375)
#define HI_DAY_COLOR vec3(0.0465375, 0.037485, 0.0465375)
#define HI_NIGHT_COLOR vec3(0.0465375, 0.037485, 0.0465375)

#define LOW_MIDDLE_COLOR vec3(0.0465375, 0.037485, 0.0465375)
#define LOW_DAY_COLOR vec3(0.0465375, 0.037485, 0.0465375)
#define LOW_NIGHT_COLOR vec3(0.0465375, 0.037485, 0.0465375)

vec3 day_color_mixer(vec3 middle, vec3 day, vec3 night, float moment) {
  // f(x) = min(−((x−.25)^2)∙20 + 1.25, 1)
  // g(x) = min(−((x−.75)^2)∙50 + 3.125, 1)

  float moment_aux = moment - 0.25;
  moment_aux = moment_aux * moment_aux;
  float day_mix = clamp(-moment_aux * 20.0 + 1.25, 0.0, 1.0);

  moment_aux = moment - 0.75;
  moment_aux = moment_aux * moment_aux;
  float night_mix = clamp(-moment_aux * 50.0 + 3.125, 0.0, 1.0);

  vec3 day_color = mix(middle, day, day_mix);
  vec3 night_color = mix(middle, night, night_mix);

  return mix(day_color, night_color, step(0.5, moment));
}

// Ambient color luma per hour in exposure calculation
const float ambient_exposure[25] =
  float[25](
  1.0, // 6
  1.0, // 7
  1.0, // 8
  1.0, // 9
  1.0, // 10
  1.0, // 11
  1.0, // 12
  1.0, // 13
  1.0, // 14
  1.0, // 15
  1.0, // 16
  1.0, // 17
  1.0, // 18
  1.0, // 19
  1.0, // 20
  1.0, // 21
  1.0, // 22
  1.0, // 23
  1.0, // 24
  1.0, // 1
  1.0, // 2
  1.0, // 3
  1.0, // 4
  1.0, // 5
  1.0 // 6
  );

// How many sky_color vs. fog_color is used for fog.
const float fog_color_mix[25] =
  float[25](
  1.0, // 6
  1.0, // 7
  1.0, // 8
  1.0, // 9
  1.0, // 10
  1.0, // 11
  1.0, // 12
  1.0, // 13
  1.0, // 14
  1.0, // 15
  1.0, // 16
  1.0, // 17
  1.0, // 18
  1.0, // 19
  1.0, // 20
  1.0, // 21
  1.0, // 22
  1.0, // 23
  1.0, // 24
  1.0, // 1
  1.0, // 2
  1.0, // 3
  1.0, // 4
  1.0, // 5
  1.0 // 6
  );

// Fog parameter per hour
const float fog_density[25] =
  float[25](
  1.0, // 6
  1.0, // 7
  1.0, // 8
  1.0, // 9
  1.0, // 10
  1.0, // 11
  1.0, // 12
  1.0, // 13
  1.0, // 14
  1.0, // 15
  1.0, // 16
  1.0, // 17
  1.0, // 18
  1.0, // 19
  1.0, // 20
  1.0, // 21
  1.0, // 22
  1.0, // 23
  1.0, // 24
  1.0, // 1
  1.0, // 2
  1.0, // 3
  1.0, // 4
  1.0, // 5
  1.0 // 6
  );

#define CANDLE_BASELIGHT vec3(0.4995, 0.38784706, 0.1998)

/* MakeUp Ultra Fast - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;

#if COLOR_SCHEME == 0  // Legacy
  #define AMBIENT_MIDDLE_COLOR vec3(0.75, 0.37941176, 0.16470588)
  #define AMBIENT_DAY_COLOR vec3(0.74, 0.74, 0.7)
  #define AMBIENT_NIGHT_COLOR vec3(0.02720588, 0.02941177, 0.03474265)

  #define HI_MIDDLE_COLOR vec3(0.17647059, 0.34901961, 0.82745098)
  #define HI_DAY_COLOR vec3(0.14, 0.27, 0.58)
  #define HI_NIGHT_COLOR vec3(0.00647058, 0.01270587, 0.03)

  #define LOW_MIDDLE_COLOR vec3(1.0, 0.50588235, 0.21960784)
  #define LOW_DAY_COLOR vec3(0.44, 0.78, 0.96)
  #define LOW_NIGHT_COLOR vec3(0.01078431, 0.02117647, 0.05)
#elif COLOR_SCHEME == 1  // Cocoa
  #define AMBIENT_MIDDLE_COLOR vec3(0.64, 0.46, 0.21)
  #define AMBIENT_DAY_COLOR vec3(0.75, 0.75, 0.478125)
  #define AMBIENT_NIGHT_COLOR vec3(0.02720588, 0.02941177, 0.03474265)

  #define HI_MIDDLE_COLOR vec3(0.09, 0.2, 0.38)
  #define HI_DAY_COLOR vec3(0.18, 0.31, 0.52)
  #define HI_NIGHT_COLOR vec3(0.014, 0.019, 0.031)

  #define LOW_MIDDLE_COLOR vec3(0.91, 0.66, 0.47)
  #define LOW_DAY_COLOR vec3(0.4, 0.75, 1.0)
  #define LOW_NIGHT_COLOR vec3(0.022, 0.029, 0.049)
#elif COLOR_SCHEME == 2  // Captain
  #define AMBIENT_MIDDLE_COLOR vec3(0.6, 0.37647059, 0.1882353)
  #define AMBIENT_DAY_COLOR vec3(0.74541177, 0.83858823, 0.99)
  #define AMBIENT_NIGHT_COLOR vec3(0.01505882, 0.03011765, 0.04)

  #define HI_MIDDLE_COLOR vec3(0.2325 , 0.27675, 0.39975)
  #define HI_DAY_COLOR vec3(0.08, 0.2, 0.39)
  #define HI_NIGHT_COLOR vec3(0.004 , 0.01  , 0.0195)

  #define LOW_MIDDLE_COLOR vec3(1.0, 0.83, 0.38)
  #define LOW_DAY_COLOR vec3(0.5, 0.7, 1.0)
  #define LOW_NIGHT_COLOR vec3(0.025, 0.035, 0.05)
#endif

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
  1.0, // 1
  1.0, // 2
  1.0, // 3
  1.0, // 4
  1.0, // 5
  1.0, // 6
  .1, // 7
  .1, // 8
  .1, // 9
  .1, // 10
  .1, // 11
  .1, // 12
  .1, // 1
  .1, // 2
  .1, // 3
  .1, // 4
  .1, // 5
  1.0 // 6
  );

// How many sky_color vs. fog_color is used for fog.
const float fog_color_mix[25] =
  float[25](
  .9, // 6
  .7, // 7
  .5, // 8
  .5, // 9
  .5, // 10
  .5, // 11
  .5, // 12
  .5, // 13
  .5, // 14
  .5, // 15
  .5, // 16
  .7, // 17
  .9, // 18
  .9, // 19
  .9, // 20
  .9, // 21
  .9, // 22
  .9, // 23
  .9, // 24
  .9, // 1
  .9, // 2
  .9, // 3
  .9, // 4
  .9, // 5
  .9 // 6
  );

// Fog parameter per hour
const float fog_density[25] =
  float[25](
  1.0, // 6
  2.5, // 7
  3.0, // 8
  3.0, // 9
  3.0, // 10
  3.0, // 11
  3.0, // 12
  3.0, // 13
  3.0, // 14
  3.0, // 15
  3.0, // 16
  2.5, // 17
  1.5, // 18
  1.75, // 19
  2.5, // 20
  3.0, // 21
  3.0, // 22
  3.0, // 23
  3.0, // 24
  3.0, // 1
  3.0, // 2
  3.0, // 3
  2.5, // 4
  1.0, // 5
  1.0 // 6
  );

// #define CANDLE_BASELIGHT vec3(0.4995, 0.38784706, 0.1998)
#define CANDLE_BASELIGHT vec3(0.24975   , 0.19392353, 0.0999)

/* MakeUp Ultra Fast - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform sampler2D gaux3;
uniform float current_hour;

#define AMBIENT_X 0.04166666666666666
#define HI_SKY_X 0.125
#define LOW_SKY_X 0.2083333333333333

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
  .75, // 7
  .1, // 8
  .1, // 9
  .1, // 10
  .1, // 11
  .1, // 12
  .1, // 1
  .1, // 2
  .1, // 3
  .1, // 4
  .75, // 5
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
  1.0, // 18
  1.0, // 19
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

const vec3 candle_baselight = vec3(0.4995, 0.38784706, 0.1998);

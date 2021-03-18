/* MakeUp - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;

#define NETHER_OMNI vec3(0.0479638 , 0.04343892, 0.04253394)
#define NETHER_DIRECT vec3(0.0529638 , 0.04843891, 0.03753393)

// Ambient color luma per hour in exposure calculation
const float ambient_exposure[25] =
  float[25](
  .1, // 6
  .1, // 7
  .1, // 8
  .1, // 9
  .1, // 10
  .1, // 11
  .1, // 12
  .1, // 13
  .1, // 14
  .1, // 15
  .1, // 16
  .1, // 17
  .1, // 18
  .1, // 19
  .1, // 20
  .1, // 21
  .1, // 22
  .1, // 23
  .1, // 24
  .1, // 1
  .1, // 2
  .1, // 3
  .1, // 4
  .1, // 5
  .1 // 6
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
  .5, // 6
  .5, // 7
  .5, // 8
  .5, // 9
  .5, // 10
  .5, // 11
  .5, // 12
  .5, // 13
  .5, // 14
  .5, // 15
  .5, // 16
  .5, // 17
  .5, // 18
  .5, // 19
  .5, // 20
  .5, // 21
  .5, // 22
  .5, // 23
  .5, // 24
  .5, // 1
  .5, // 2
  .5, // 3
  .5, // 4
  .5, // 5
  .5 // 6
  );

#define CANDLE_BASELIGHT vec3(0.4995, 0.38784706, 0.1998)

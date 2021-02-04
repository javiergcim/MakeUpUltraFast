#version 130
/* MakeUp Ultra Fast - gbuffers_clouds.vsh
Render: Basic elements

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
varying vec4 tint_color;
varying float frog_adjust;
varying vec3 current_fog_color;

uniform float far;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float rainStrength;
uniform int isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#if AA_TYPE == 1
  #include "/src/taa_offset.glsl"
#endif

void main() {
  // Simplified light calculation for this basic elements
  vec2 illumination = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  float visible_sky = illumination.y * 1.105 - .10495;

  // vec3 direct_light_color =
  //   texture(gaux3, vec2(AMBIENT_X, current_hour)).rgb * (1.0 - rainStrength);

  vec3 direct_light_color = day_color_mixer(
    AMBIENT_MIDDLE_COLOR,
    AMBIENT_DAY_COLOR,
    AMBIENT_NIGHT_COLOR,
    day_moment
    ) * (1.0 - rainStrength);

  vec3 hi_sky_color = day_color_mixer(
    HI_MIDDLE_COLOR,
    HI_DAY_COLOR,
    HI_NIGHT_COLOR,
    day_moment
    );

  direct_light_color = mix(
    direct_light_color,
    HI_SKY_RAIN_COLOR * luma(hi_sky_color),
    rainStrength
  );

  hi_sky_color = mix(
    hi_sky_color,
    HI_SKY_RAIN_COLOR * luma(hi_sky_color),
    rainStrength
  );

  vec3 omni_light = mix(hi_sky_color, direct_light_color, OMNI_TINT) *
    visible_sky * visible_sky;

  vec3 candle_color = CANDLE_BASELIGHT * cube_pow(illumination.x);
  vec3 final_light = (direct_light_color * illumination.y) + candle_color;

  tint_color = gl_Color * vec4(final_light, 1.0);
  #include "/src/position_vertex.glsl"
  #include "/src/fog_vertex.glsl"
}

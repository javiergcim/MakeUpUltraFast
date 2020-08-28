#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NICE_WATER 1  // [0 1] Turn on for reflection and refraction capabilities.

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;

// 'Global' constants from system
uniform int worldTime;
uniform sampler2D texture;
uniform int isEyeInWater;
uniform int entityId;
uniform float nightVision;
uniform float rainStrength;
uniform float wetness;
uniform float far;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#include "/lib/color_utils.glsl"

void main() {
  // Custom light (lmcoord.x: candle, lmcoord.y: ambient) ----
  vec2 illumination = lmcoord;

  // Tomamos el color de ambiente con base a la hora
  vec3 ambient_currentlight =
    mix(
      ambient_baselight[current_hour_floor],
      ambient_baselight[current_hour_ceil],
      current_hour_fract
    ) * ambient_multiplier;

  if (illumination.y < 0.08) {  // lmcoord.y artifact remover
    illumination.y = 0.09;
  }
  illumination.y = (illumination.y * 1.085) - .085;  // Avoid dimmed light

  // Ajuste de intensidad luminosa bajo el agua
  if (isEyeInWater == 1.0) {
    illumination.y = (illumination.y * .95) + .05;
  }

  vec3 ambient_color =
    ambient_currentlight * illumination.y;
  vec3 candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Se ajusta luz ambiental en tormenta
  ambient_color = ambient_color * (1.0 - (rainStrength * .3));

  vec3 real_light =
    mix(ambient_color + candle_color, vec3(1.0), nightVision * .125);

  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  // Se agrega mapa de color y sombreado nativo
  block_color *= (tint_color * vec4(real_light, 1.0));

  // Indica que tan oculto estás del cielo
  float visible_sky = clamp(lmcoord.y * 1.5 - .5, 0.0, 1.0);

  // New fog
  float fog_mix_level;
  float fog_density_coeff;
  float fog_intensity_coeff;
  vec3 current_fog_color;
  if (isEyeInWater == 0.0) { // Normal
    // Fog color calculation
    fog_mix_level = mix(
      fog_color_mix[current_hour_floor],
      fog_color_mix[current_hour_ceil],
      current_hour_fract
      );
    // Fog intensity calculation
    fog_density_coeff = mix(
      fog_density[current_hour_floor],
      fog_density[current_hour_ceil],
      current_hour_fract
      );
    fog_intensity_coeff = max(
      visible_sky,
      eyeBrightnessSmooth.y / 240.0
    );
    current_fog_color = mix(skyColor, gl_Fog.color.rgb, fog_mix_level);
  } else if (isEyeInWater == 1.0) {  // Underwater
    fog_density_coeff = 0.5;
    fog_intensity_coeff = 1.0;
    current_fog_color = waterfog_baselight * real_light;
  } else {  // Lava
    fog_density_coeff = 0.5;
    fog_intensity_coeff = 1.0;
    current_fog_color = gl_Fog.color.rgb;
  }

  float frog_adjust = (gl_FogFragCoord / far) * fog_intensity_coeff;
  block_color.rgb =
    mix(
      block_color.rgb,
      current_fog_color,
      pow(frog_adjust, mix(fog_density_coeff, .5, wetness))
    );

  gl_FragData[0] = block_color;
  #if NICE_WATER == 1
    gl_FragData[5] = block_color;
  #else
    gl_FragData[1] = vec4(0.0);
  #endif
}

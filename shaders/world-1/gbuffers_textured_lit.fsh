#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Small entities, hand objects

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
uniform sampler2D lightmap;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float wetness;
uniform float far;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#include "/lib/color_utils_nether.glsl"

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
  illumination.y = (illumination.y * .5) + .5;  // Avoid absolut darkness

  // Ajuste de intensidad luminosa bajo el agua
  if (isEyeInWater == 1.0) {
    illumination.y = (illumination.y * .95) + .05;
  }

  vec3 ambient_color =
    ambient_currentlight * illumination.y;
  vec3 candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Se ajusta luz ambiental en tormenta
  vec3 real_light = ambient_color * (1.0 - (rainStrength * .3));

  vec3 omni_light = skyColor * mix(
    omni_force[current_hour_floor],
    omni_force[current_hour_ceil],
    current_hour_fract
  );

  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  // Indica que tan oculto estás del cielo
  float visible_sky = clamp(lmcoord.y * 1.5 - .5, 0.0, 1.0);

  float direct_light_strenght = 1.0;

  omni_light *= illumination.y;

  // Calculamos iluminación de dirección
  if ((worldTime >= 0 && worldTime <= 12700) || worldTime > 23000) {  // Día
    direct_light_strenght = dot(normal, sun_vec);
  } else if (worldTime > 12700 && worldTime <= 13400 ) { // Anochece
    float sun_light_strenght = dot(normal, sun_vec);
    float moon_light_strenght = dot(normal, moon_vec);
    float light_mix = (worldTime - 12700) / 700.0;
    // Calculamos la cantidad de mezcla de luz de sol y luna
    direct_light_strenght =
      mix(sun_light_strenght, moon_light_strenght, light_mix);

  } else if (worldTime > 13400 && worldTime <= 22300) {  // Noche
    direct_light_strenght = dot(normal, moon_vec);

  } else if (worldTime > 22300) {  // Amanece
    float sun_light_strenght = dot(normal, sun_vec);
    float moon_light_strenght = dot(normal, moon_vec);
    float light_mix = (worldTime - 22300) / 700.0;
    // Calculamos la cantidad de mezcla de luz de sol y luna
    direct_light_strenght =
      mix(moon_light_strenght, sun_light_strenght, light_mix);
  }

  // Escalamos para evitar negros en zonas oscuras
  direct_light_strenght = (direct_light_strenght * .45) + .55;
  float candle_cave_strenght = (direct_light_strenght * .5) + .5;

  direct_light_strenght =
    mix(1.0, direct_light_strenght, visible_sky);
  candle_cave_strenght =
    mix(candle_cave_strenght, 1.0, visible_sky);

  // Para evitar iluminación plana en cuevas
  candle_color *= candle_cave_strenght;

  direct_light_strenght = clamp((direct_light_strenght + illumination.y - 1.0), 0.0, 1.0);
  real_light = (real_light * direct_light_strenght) + candle_color + omni_light;
  real_light = mix(real_light, vec3(1.0), nightVision * .125);
  block_color *= tint_color * vec4(real_light, 1.0);

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
    fog_intensity_coeff = 1.0;
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
      pow(clamp(frog_adjust, 0.0, 1.0), mix(fog_density_coeff, .5, wetness))
    );

  gl_FragData[0] = block_color;
  #if NICE_WATER == 1
    gl_FragData[5] = block_color;
  #else
    gl_FragData[1] = vec4(0.0);
  #endif
}

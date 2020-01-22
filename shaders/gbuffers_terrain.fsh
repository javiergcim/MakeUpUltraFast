#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/globals.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float grass;
varying float leaves;
varying float emissive;
varying float magma;

// 'Global' constants from system
uniform int worldTime;
uniform sampler2D texture;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float wetness;
uniform float far;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;

#include "/lib/color_utils.glsl"

void main() {
  // Custom light (lmcoord.x: candle, lmcoord.y: ambient) ----
  vec2 illumination = lmcoord;

  // x: Block, y: Sky ---
  float ambient_bright = eyeBrightnessSmooth.y / 240.0;

  // Daytime
  float current_hour = worldTime / 1000.0;
  int current_hour_floor = int(floor(current_hour));
  int current_hour_ceil = int(ceil(current_hour));
  float current_hour_fract = fract(current_hour);

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
    ambient_currentlight;
  vec3 candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Se ajusta luz ambiental en tormenta
  vec3 real_light = ambient_color * (1.0 - (rainStrength * .4));

  vec3 omni_light = skyColor * mix(
    omni_force[current_hour_floor],
    omni_force[current_hour_ceil],
    current_hour_fract
  );

  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  // Indica que tan oculto estás del cielo
  float direct_light_coefficient = clamp(lmcoord.y * 1.1 - .1, 0.0, 1.0);

  if (emissive > 0.5) {  // Es emisivo
    block_color *= (tint_color * vec4((candle_color + (real_light * illumination.y)) * 1.2, 1.0));

  } else if (magma > 0.5) {  // Es magma (emisión nueva)
    block_color *= (tint_color * vec4(vec3(lmcoord.x * 1.1), 1.0));

  } else {  // No es bloque emisivo

    float direct_light_strenght = 1.0;
    omni_light *= illumination.y;

     // Si no estamos ocultos al cielo calculamos iluminación de dirección
    if (direct_light_coefficient > 0.0) {
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

      direct_light_strenght = (direct_light_strenght * .45) + .55;
      direct_light_strenght =
        mix(1.0, direct_light_strenght, direct_light_coefficient);
    }

    if (grass > .5) {  // Es "planta"
      direct_light_strenght = mix(direct_light_strenght, 1.0, .3);
    } else if(leaves > .5) {
      direct_light_strenght = mix(direct_light_strenght, 1.0, .2);
    }

    omni_light *= (-direct_light_strenght + 1.0);

    direct_light_strenght = clamp((direct_light_strenght + illumination.y - 1.0), 0.0, 1.0);
    real_light = ((real_light * direct_light_strenght) + candle_color + omni_light);
    real_light = mix(real_light, vec3(1.0), nightVision * .125);
    block_color *= tint_color * vec4(real_light, 1.0);
  }

  // Posproceso de la niebla
  if (isEyeInWater == 1.0) {
  block_color.rgb =
      mix(
        block_color.rgb,
        waterfog_baselight * real_light,
        1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0)
      );
  } else if (isEyeInWater == 2.0) {
    block_color.rgb =
      mix(
        block_color.rgb,
        gl_Fog.color.rgb * real_light,
        1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0)
      );
  } else {
    // Fog intensity calculation
    float fog_intensity_coeff = mix(
      fog_density[current_hour_floor],
      fog_density[current_hour_ceil],
      current_hour_fract
      );
    // Intensidad de niebla (baja cuando oculto del cielo)
    fog_intensity_coeff = max(fog_intensity_coeff, wetness * 1.4);
    fog_intensity_coeff *= max(direct_light_coefficient, ambient_bright);
    float new_frog = (((gl_FogFragCoord / far) * (2.0 - fog_intensity_coeff)) - (1.0 - fog_intensity_coeff)) * far;
    float frog_adjust = new_frog / far;

    // Fog color calculation
    float fog_mix_level = mix(
      fog_color_mix[current_hour_floor],
      fog_color_mix[current_hour_ceil],
      current_hour_fract
      );
    vec3 current_fog_color = mix(skyColor, gl_Fog.color.rgb, fog_mix_level);

    block_color.rgb =
      mix(
        block_color.rgb,
        current_fog_color,
        pow(clamp(frog_adjust, 0.0, 1.0), 2)
      );
  }

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;
}

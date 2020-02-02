#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Particles

Javier Garduño - GNU Lesser General Public License v3.0
*/

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
    ambient_currentlight * illumination.y;
  vec3 candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Se ajusta luz ambiental en tormenta
  ambient_color = ambient_color * (1.0 - (rainStrength * .4));

  vec3 real_light =
    mix(ambient_color + candle_color, vec3(1.0), nightVision * .125);

  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  // Se agrega mapa de color y sombreado nativo
  block_color *= (tint_color * vec4(real_light, 1.0));

  // Indica que tan oculto estás del cielo
  float direct_light_coefficient = clamp(lmcoord.y * 1.5 - .5, 0.0, 1.0);

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

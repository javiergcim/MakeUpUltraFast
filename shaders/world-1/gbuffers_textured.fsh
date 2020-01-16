#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define REFLECTION 1 // [0 1] Activate reflection
#define REFRACTION 1 // [0 1] Activate refraction

#include "/lib/globals.glsl"
#include "/lib/color_utils_nether.glsl"

// Varyings (per thread shared variables)
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec4 tint_color;

// 'Global' constants from system
uniform sampler2D texture;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float far;
uniform float wetness;

void main() {
  // Custom light (lmcoord.x: candle, lmcoord.y: ambient) ----
  vec2 illumination = lmcoord.xy;
  // Tomamos el color de ambiente
  vec3 ambient_currentlight = ambient_baselight;

  illumination.y *= illumination.y;  // Non-linear decay
  illumination.y = (illumination.y * .989) + .011;  // Avoid absolute dark

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
    mix(ambient_color + candle_color, vec3(1.0), nightVision * .125) * 4.0;

  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord.xy);

  // Indica cuanta iluminación basada en dirección de fuente de luz se usará
  float direct_light_coefficient = clamp(lmcoord.y * 2.0 - 1.0, 0.0, 1.0);

  // Se agrega mapa de color y sombreado nativo
  block_color *= (tint_color * vec4(real_light, 1.0));

  // Posproceso de la niebla
  if (isEyeInWater == 1.0) {
		block_color.rgb =
      mix(
        block_color.rgb,
        waterfog_baselight,
        1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0)
      );
  } else if (isEyeInWater == 2.0) {
    block_color.rgb =
      mix(
        block_color.rgb,
        gl_Fog.color.rgb,
        1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0)
      );
	} else {
    // Fog intensity calculation
    float fog_intensity_coeff = mix(
      fog_density[int(floor(current_hour))],
      fog_density[int(ceil(current_hour))],
      fract(current_hour)
      );
    // Intensidad de niebla (baja cuando oculto del cielo)
    fog_intensity_coeff = max(fog_intensity_coeff, wetness * 1.4);
    if (fog_intensity_coeff > 1.0) {
      fog_intensity_coeff = mix(1.0, fog_intensity_coeff, direct_light_coefficient);
    }
    float new_frog = (((gl_FogFragCoord / far) * (2.0 - fog_intensity_coeff)) - (1.0 - fog_intensity_coeff)) * far;
    float frog_adjust = new_frog / far;

    // Fog color calculation
    vec3 current_fog_color = gl_Fog.color.rgb;

    block_color.rgb =
      mix(
        block_color.rgb,
        current_fog_color,
        pow(clamp(frog_adjust, 0.0, 1.0), 2)
      );
  }

  gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;
	// gl_FragData[1] = vec4(0.0);  // Not needed. Performance trick
}

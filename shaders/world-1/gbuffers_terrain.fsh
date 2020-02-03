#version 120
/* MakeUp Ultra Fast - gbuffers_textured.fsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/color_utils_nether.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float magma;

// 'Global' constants from system
uniform sampler2D texture;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float far;
uniform float wetness;

void main() {
  // Custom light (lmcoord.x: candle, lmcoord.y: ambient) ----
  vec2 illumination = lmcoord;
  // Tomamos el color de ambiente
  vec3 ambient_currentlight = ambient_baselight;

  if (illumination.y < 0.09) {  // lmcoord.y artifact remover
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

  vec3 real_light =
    mix(ambient_color + candle_color, vec3(1.0), nightVision * .125) * 4.0;
    // mix(candle_color, vec3(1.0), nightVision * .125) * 4.0;

  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  // Se agrega mapa de color y sombreado nativo
  if (magma < .5) {
    block_color *= (tint_color * vec4(real_light, 1.0));
  } else {
    block_color *= (tint_color * vec4(ambient_baselight, 1.0) * 2.0);
  }

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
    float fog_intensity_coeff = fog_density;
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
}

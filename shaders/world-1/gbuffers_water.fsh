#version 120
/* MakeUp Ultra Fast - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NICE_WATER 1  // [0 1] Turn on for reflection and refraction capabilities.
#define TINTED_WATER 1  // [0 1] Use the resource pack color for water.
#define REFLECTION 1  // [0 1] Activate reflectons
#define REFRACTION 1  // [0 1] Activate refractions
#define SSR_METHOD 0  // [0 1] Flipped Image is inaccurate but faster. Raytrace is more accurate but slower.

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float iswater;
varying float istranslucent;
varying vec4 position2;
varying vec4 worldposition;
varying vec3 tangent;
varying vec3 binormal;

// 'Global' constants from system
uniform int worldTime;
uniform sampler2D texture;
uniform int isEyeInWater;
uniform int entityId;
uniform float nightVision;
uniform float rainStrength;
uniform float wetness;
uniform float near;
uniform float far;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform sampler2D noisetex;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D gaux2;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform ivec2 eyeBrightnessSmooth;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

#include "/lib/color_utils_nether.glsl"

#if NICE_WATER == 1
  #include "/lib/water.glsl"
#endif

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

  vec3 candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Se ajusta luz ambiental en tormenta
  vec3 real_light = ambient_currentlight * (1.0 - (rainStrength * .4));

  vec3 omni_light = skyColor * mix(
    omni_force[current_hour_floor],
    omni_force[current_hour_ceil],
    current_hour_fract
  );

  // Indica cuanta iluminación basada en dirección de fuente de luz se usará
  float visible_sky = clamp(lmcoord.y * 1.1 - .1, 0.0, 1.0);
  float direct_light_strenght = 1.0;

  omni_light *= illumination.y;

   // Si no estamos ocultos al cielo calculamos iluminación de dirección
  if (visible_sky > 0.0) {
    if ((worldTime >= 0 && worldTime <= 12700) || worldTime > 23000) {  // Día
      direct_light_strenght = dot(normal, sun_vec);
    //
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
      // Calculamos la cantiidad de mezcla de luz de sol y luna
      direct_light_strenght =
        mix(moon_light_strenght, sun_light_strenght, light_mix);
    }

    direct_light_strenght = (direct_light_strenght * .45) + .55;
    direct_light_strenght =
      mix(1.0, direct_light_strenght, visible_sky);
  }

  // Prepare Sky/Fog color calculation
  float fog_mix_level = mix(
    fog_color_mix[current_hour_floor],
    fog_color_mix[current_hour_ceil],
    current_hour_fract
    );
  // Fog color calculation
  vec3 current_fog_color = mix(skyColor, gl_Fog.color.rgb, fog_mix_level);

  // Begin water code ---------------

  vec4 block_color;

  if (iswater > .5) {

    #if NICE_WATER == 1

      #if TINTED_WATER == 1
        block_color.rgb = mix(
          (tint_color.rgb * direct_light_strenght) + candle_color,
          vec3(1.0),
          .3
        );
      #else
        block_color.rgb = vec3(1.0);
      #endif

      vec3 water_normal_base = waterwavesToNormal(worldposition.xyz);

      vec3 fragposition0 = toNDC(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z));

      block_color = vec4(
        refraction(
          fragposition0,
          block_color.rgb,
          water_normal_base
        ),
        1.0
      );

      block_color.rgb = waterShader(
        fragposition0,
        getNormals(water_normal_base),
        block_color.rgb,
        lmcoord.y > 0.9 ? 1.0 : 0.0,
        current_fog_color
      );

    #else
      // Toma el color puro del bloque
      block_color = texture2D(texture, texcoord);
      direct_light_strenght = clamp((direct_light_strenght + illumination.y - 1.0), 0.0, 1.0);
      real_light = ((real_light * direct_light_strenght) + candle_color + omni_light);
      real_light = mix(real_light, vec3(1.0), nightVision * .125);
      block_color *= tint_color * vec4(real_light, 1.0);

      block_color.a = .66;
    #endif

  } else {  // End water shader code ------------------------
    // Toma el color puro del bloque
    block_color = texture2D(texture, texcoord);

    direct_light_strenght = clamp((direct_light_strenght + illumination.y - 1.0), 0.0, 1.0);
    real_light = (real_light * direct_light_strenght) + candle_color + omni_light;
    real_light = mix(real_light, vec3(1.0), nightVision * .125);
    block_color *= tint_color * vec4(real_light, 1.0);
  }

  // New fog
  float fog_density_coeff;
  float fog_intensity_coeff;
  if (isEyeInWater == 0.0) { // Normal
    // Fog intensity calculation
    fog_density_coeff = mix(
      fog_density[current_hour_floor],
      fog_density[current_hour_ceil],
      current_hour_fract
      );
    fog_intensity_coeff = 1.0;
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
  gl_FragData[1] = vec4(0.0);  // ¿Performance?
}

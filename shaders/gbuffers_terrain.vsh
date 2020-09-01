#version 120
/* MakeUp Ultra Fast - gbuffers_textured.vsh
Render: Almost everything

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define ENTITY_SMALLGRASS   10031.0  //
#define ENTITY_LOWERGRASS   10175.0  // Lower half only in 1.13+
#define ENTITY_UPPERGRASS   10176.0 // Upper half only used in 1.13+
#define ENTITY_SMALLENTS    10059.0  // sapplings(6), dandelion(37), rose(38), carrots(141), potatoes(142), beetroot(207)
#define ENTITY_LEAVES       10018.0 // Leaves
#define ENTITY_VINES        10106.0 // Vines
#define ENTITY_EMISSIVE     10089.0 // Emissors like candels and others
#define ENTITY_MAGMA        10213.0 // Emissors like magma
#define WAVING 1 // [0 1] Waving entities

// 'Global' constants from system
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform float light_mix;
uniform float far;

uniform sampler2D texture;
uniform float nightVision;
uniform float rainStrength;
uniform vec3 skyColor;
uniform ivec2 eyeBrightnessSmooth;

#if WAVING == 1
  uniform vec3 cameraPosition;
  uniform mat4 gbufferModelView;
  uniform mat4 gbufferModelViewInverse;
  uniform float frameTimeCounter;
  uniform float wetness;
  uniform sampler2D noisetex;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 normal;
varying float emissive;
varying float magma;
varying vec3 candle_color;
varying vec3 pseudo_light;
varying vec3 real_light;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;
varying float illumination_y;

attribute vec4 mc_Entity;
#if WAVING == 1
  attribute vec2 mc_midTexCoord;
  #include "/lib/vector_utils.glsl"
#endif

#include "/lib/color_utils.glsl"

void main() {
  texcoord = gl_MultiTexCoord0.xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

  #if WAVING == 1

    vec3 position =
      mat3(gbufferModelViewInverse) *
      (gl_ModelViewMatrix * gl_Vertex).xyz +
      gbufferModelViewInverse[3].xyz;

    vec3 vworldpos = position.xyz + cameraPosition;

    if (mc_Entity.x == ENTITY_LOWERGRASS ||
        mc_Entity.x == ENTITY_UPPERGRASS ||
        mc_Entity.x == ENTITY_SMALLGRASS ||
        mc_Entity.x == ENTITY_SMALLENTS ||
        mc_Entity.x == ENTITY_LEAVES)
    {
      float amt = float(texcoord.y < mc_midTexCoord.y);

      if (mc_Entity.x == ENTITY_UPPERGRASS) {
        amt += 1.0;
      } else if (mc_Entity.x == ENTITY_LEAVES) {
        amt = .5;
      }

      position.xyz += sildursMove(vworldpos.xyz,
      0.0041,
      0.0070,
      0.0044,
      0.0038,
      0.0240,
      0.0000,
      vec3(0.8, 0.0, 0.8),
      vec3(0.4, 0.0, 0.4)) * amt * lmcoord.y * (1.0 + (wetness * 3.0));
    }

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);

  #else

    gl_Position = ftransform();

  #endif

  gl_FogFragCoord = length(gl_Position.xyz);

  tint_color = gl_Color;

  normal = normalize(gl_NormalMatrix * gl_Normal);

  vec3 sun_vec = normalize(sunPosition);
  // moon_vec = normalize(moonPosition);
  vec3 moon_vec = -sun_vec;

  // Grass entities
  float grass;
  float leaves;
  if (
    mc_Entity.x == ENTITY_SMALLGRASS ||
    mc_Entity.x == ENTITY_LOWERGRASS ||
    mc_Entity.x == ENTITY_VINES ||
    mc_Entity.x == ENTITY_UPPERGRASS ||
    mc_Entity.x == ENTITY_SMALLENTS
  ) {
    grass = 1.0;
    leaves = 0.0;
    emissive = 0.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_LEAVES){  // Leaves
    grass = 0.0;
    leaves = 1.0;
    emissive = 0.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_EMISSIVE) { // Emissive entities
    grass = 0.0;
    leaves = 0.0;
    emissive = 1.0;
    magma = 0.0;
  } else if (mc_Entity.x == ENTITY_MAGMA) {
    grass = 0.0;
    leaves = 0.0;
    emissive = 0.0;
    magma = 1.0;
  } else {
    grass = 0.0;
    leaves = 0.0;
    emissive = 0.0;
    magma = 0.0;
  }

  // Base illumination ---------------------------------------------------------
  // Custom light (lmcoord.x: candle, lmcoord.y: sky direct) ----
  vec2 illumination = lmcoord;

  if (illumination.y < 0.09) {  // lmcoord.y artifact remover
    illumination.y = 0.09;
  }
  illumination.y = (illumination.y * 1.085) - .085;  // Avoid dimmed light

  // Ajuste de intensidad luminosa bajo el agua
  if (isEyeInWater == 1.0) {
    illumination.y = (illumination.y * .95) + .05;
  }

  illumination_y = illumination.y;

  // Tomamos el color de luz directa con base a la hora
  vec3 sky_currentlight =
    mix(
      ambient_baselight[current_hour_floor],
      ambient_baselight[current_hour_ceil],
      current_hour_fract
    ) * ambient_multiplier;

  candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Ajuste de luz directa en tormenta
  pseudo_light = sky_currentlight * (1.0 - (rainStrength * .3));

  // Color de luz omnidireccional
  vec3 omni_light = skyColor * mix(
    omni_force[current_hour_floor],
    omni_force[current_hour_ceil],
    current_hour_fract
  );

  // Indica que tan oculto estás del cielo
  float visible_sky = clamp(lmcoord.y * 1.1 - .1, 0.0, 1.0);

  // ¿Es bloque no emisivo?
  if (emissive < 0.5 && magma < 0.5) {  // Es bloque no emisivo

    float direct_light_strenght = 1.0;
    omni_light *= illumination_y;
    if (visible_sky > 0.0) {
      // Fuerza de luz según dirección
      float sun_light_strenght = dot(normal, sun_vec);
      float moon_light_strenght = dot(normal, moon_vec);
      direct_light_strenght =
        mix(moon_light_strenght, sun_light_strenght, light_mix);

      direct_light_strenght = (direct_light_strenght * .45) + .55;
      direct_light_strenght = mix(1.0, direct_light_strenght, visible_sky);
    }

    if (grass > .5) {  // Es "planta"
      direct_light_strenght = mix(direct_light_strenght, 1.0, .3);
    } else if (leaves > .5) {
      direct_light_strenght = mix(direct_light_strenght, 1.0, .2);
    }

    direct_light_strenght = clamp((direct_light_strenght + illumination.y - 1.0), 0.0, 1.0);
    real_light = (pseudo_light * direct_light_strenght) + candle_color + omni_light;
    real_light = mix(real_light, vec3(1.0), nightVision * .125);
  }

  // Fog
  float fog_mix_level;
  float fog_intensity_coeff;
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

  frog_adjust = (gl_FogFragCoord / far) * fog_intensity_coeff;
}

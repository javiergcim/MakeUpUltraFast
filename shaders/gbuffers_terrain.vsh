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
uniform int worldTime;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int isEyeInWater;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

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
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float grass;
varying float leaves;
varying float emissive;
varying float iswater;
varying float magma;

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

  sun_vec = normalize(sunPosition);
  // moon_vec = normalize(moonPosition);
  moon_vec = -sun_vec;

  // Grass entities
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

  // Base illumination
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

  // Ajuste de intensidad luminosa bajo el agua
  if (isEyeInWater == 1.0) {
    illumination.y = (illumination.y * .95) + .05;
  }

  // Tomamos el color de luz directa con base a la hora
  vec3 sky_currentlight =
    mix(
      ambient_baselight[current_hour_floor],
      ambient_baselight[current_hour_ceil],
      current_hour_fract
    ) * ambient_multiplier;

  vec3 candle_color =
    candle_baselight * illumination.x * illumination.x * illumination.x;

  // Ajuste de luz directa en tormenta
  vec3 real_light = sky_currentlight * (1.0 - (rainStrength * .3));

  // Color de luz omnidireccional
  vec3 omni_light = skyColor * mix(
    omni_force[current_hour_floor],
    omni_force[current_hour_ceil],
    current_hour_fract
  );

  // Indica que tan oculto estás del cielo
  float visible_sky = clamp(lmcoord.y * 1.1 - .1, 0.0, 1.0);


}

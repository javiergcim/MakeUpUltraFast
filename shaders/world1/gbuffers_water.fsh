#version 120
/* MakeUp Ultra Fast - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define WATER_F

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 current_fog_color;
varying float frog_adjust;
varying float fog_density_coeff;
varying vec3 water_normal;
varying float block_type;
varying vec4 worldposition;
varying vec4 position2;
varying vec3 tangent;
varying vec3 binormal;

varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;

#if SHADOW_CASTING == 1
  varying float shadow_mask;
  varying vec3 shadow_pos;
#endif

// 'Global' constants from system
uniform sampler2D texture;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform float frameTimeCounter;
uniform int isEyeInWater;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;

uniform float nightVision;
uniform float rainStrength;

#if SHADOW_CASTING == 1
  uniform sampler2D gaux2;
  uniform sampler2DShadow shadowtex1;
  uniform float shadow_force;
#endif

#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water.glsl"
#include "/lib/cristal.glsl"

#if SHADOW_CASTING == 1
  #include "/lib/shadow_frag.glsl"
#endif

void main() {
  vec4 block_color;
  vec3 fragposition =
    to_NDC(
      vec3(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z)
      );

  if (block_type > 2.5) {  // Water
    #if TINTED_WATER == 1
      block_color.rgb = mix(
        tint_color.rgb,
        vec3(1.0),
        .3
      );
    #else
      block_color.rgb = vec3(1.0);
    #endif

    vec3 water_normal_base = normal_waves(worldposition.xzy);

    block_color = vec4(
      refraction(
        fragposition,
        block_color.rgb,
        water_normal_base
      ),
      1.0
    );

    block_color.rgb = water_shader(
      fragposition,
      get_normals(water_normal_base),
      block_color.rgb,
      current_fog_color
    );

  } else if (block_type > 1.5) {  // Glass
    // Toma el color puro del bloque
    block_color = texture2D(texture, texcoord) * tint_color;
    float shadow_c;

    #if SHADOW_CASTING == 1
      if (rainStrength < .95 && lmcoord.y > 0.005) {
        shadow_c = get_shadow(shadow_pos);
        shadow_c = mix(shadow_c, 1.0, rainStrength);
      } else {
        shadow_c = 1.0;
      }

      if (shadow_mask < 0.0) {
        shadow_c = 0.0;
      }

    #else
      shadow_c = 1.0;
    #endif

    vec3 real_light =
      omni_light +
      (direct_light_color * direct_light_strenght * shadow_c) * (1.0 - rainStrength) +
      candle_color;

    block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

    block_color = cristal_shader(
      fragposition,
      water_normal,
      block_color,
      real_light
    );

  } else if (block_type > .5){  // Portal
    // Toma el color puro del bloque
    block_color = texture2D(texture, texcoord) * tint_color;
    float shadow_c;

    #if SHADOW_CASTING == 1
      if (rainStrength < .95 && lmcoord.y > 0.005) {
        shadow_c = get_shadow(shadow_pos);
        shadow_c = mix(shadow_c, 1.0, rainStrength);
      } else {
        shadow_c = 1.0;
      }

      if (shadow_mask < 0.0) {
        shadow_c = 0.0;
      }

    #else
      shadow_c = 1.0;
    #endif

    vec3 real_light =
      omni_light +
      (direct_light_color * direct_light_strenght * shadow_c) * (1.0 - rainStrength) +
      candle_color +
      .2;

    block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);
  } else {  // ?
    // Toma el color puro del bloque
    block_color = texture2D(texture, texcoord) * tint_color;
    float shadow_c;

    #if SHADOW_CASTING == 1
      if (rainStrength < .95 && lmcoord.y > 0.005) {
        shadow_c = get_shadow(shadow_pos);
        shadow_c = mix(shadow_c, 1.0, rainStrength);
      } else {
        shadow_c = 1.0;
      }

      if (shadow_mask < 0.0) {
        shadow_c = 0.0;
      }

    #else
      shadow_c = 1.0;
    #endif

    vec3 real_light =
      omni_light +
      (direct_light_color * direct_light_strenght * shadow_c) * (1.0 - rainStrength) +
      candle_color +
      .2;

    block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);
  }

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

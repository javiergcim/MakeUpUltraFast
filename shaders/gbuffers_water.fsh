#version 120
/* MakeUp - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define WATER_F

#include "/lib/config.glsl"
#include "/lib/color_utils.glsl"

// 'Global' constants from system
uniform sampler2D tex;
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
uniform int frame_mod;
uniform float frameTimeCounter;
uniform int isEyeInWater;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;

uniform float nightVision;
uniform float rainStrength;
uniform vec3 skyColor;
uniform float light_mix;
uniform ivec2 eyeBrightnessSmooth;

uniform sampler2D colortex7;

#ifdef SHADOW_CASTING
  uniform sampler2DShadow shadowtex1;
#endif

uniform sampler2D colortex5;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 current_fog_color;  // Flat
varying float frog_adjust;
varying vec3 water_normal;  // Flat
varying float block_type;  // Flat
varying vec4 worldposition;
varying vec4 position2;
varying vec3 tangent;
varying vec3 binormal;

varying vec3 direct_light_color;  // Flat
varying vec3 candle_color;
varying float direct_light_strenght;
varying vec3 omni_light;
varying float visible_sky;

#ifdef SHADOW_CASTING
  varying vec3 shadow_pos;
  varying float shadow_diffuse;
#endif

varying vec3 up_vec;  // Flat

#include "/lib/projection_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water.glsl"

#ifdef SHADOW_CASTING
  #include "/lib/shadow_frag.glsl"
#endif

#include "/lib/luma.glsl"

void main() {
  vec4 block_color = texture2D(tex, texcoord) * tint_color;
  vec3 fragposition =
    to_screen_space(
      vec3(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z)
      );

    vec3 water_normal_base = normal_waves(worldposition.xzy);
    vec3 surface_normal = get_normals(water_normal_base);
    vec3 flat_normal = get_normals(vec3(0.0, 0.0, 1.0));
    float normal_dot_eye = dot(flat_normal, normalize(fragposition));
    float fresnel = square_pow(1.0 + normal_dot_eye);

  // Reflected sky color calculation
  vec3 hi_sky_color = day_blend(
    HI_MIDDLE_COLOR,
    HI_DAY_COLOR,
    HI_NIGHT_COLOR
    );

  hi_sky_color = mix(
    hi_sky_color,
    HI_SKY_RAIN_COLOR * luma(hi_sky_color),
    rainStrength
  );

  vec3 low_sky_color = day_blend(
    LOW_MIDDLE_COLOR,
    LOW_DAY_COLOR,
    LOW_NIGHT_COLOR
    );

  low_sky_color = mix(
    low_sky_color,
    LOW_SKY_RAIN_COLOR * luma(low_sky_color),
    rainStrength
  );

  vec3 reflect_water_vec = reflect(fragposition, surface_normal);

  vec3 sky_color_reflect;
  if (isEyeInWater == 0 || isEyeInWater == 2) {
    sky_color_reflect = mix(
      low_sky_color,
      hi_sky_color,
      sqrt(clamp(dot(normalize(reflect_water_vec), up_vec), 0.0001, 1.0))
      );
  } else {
    sky_color_reflect =
      hi_sky_color * .5 * ((eyeBrightnessSmooth.y * .8 + 48) * 0.004166666666666667);
  }

  #if SSR_TYPE == 0
    float dither = 1.0;
  #else
    #if MC_VERSION >= 11300
      #if AA_TYPE == 0
        float dither = 2.0 + (texture_noise_64(gl_FragCoord.xy, colortex5)) * 0.2;
      #else
        float dither = 2.0 + (shifted_texture_noise_64(gl_FragCoord.xy, colortex5)) * 0.2;
      #endif
    #else
      #if AA_TYPE == 0
        float dither = 2.0 + (dither_grad_noise(gl_FragCoord.xy)) * 0.2;
      #else
        float dither = 2.0 + (timed_hash12(gl_FragCoord.xy)) * 0.2;
      #endif
    #endif
  #endif

  if (block_type > 2.5) {  // Water
    #if MC_VERSION >= 11300
      #if WATER_TEXTURE == 1
        block_color.rgb = mix(
          vec3(1.0),
          tint_color.rgb,
          clamp(fresnel * .5 + WATER_TINT, 0.0, 1.0)
        ) * texture2D(tex, texcoord).rgb;
      #else
        block_color.rgb = mix(
          vec3(1.0),
          tint_color.rgb,
          clamp(fresnel * .5 + WATER_TINT, 0.0, 1.0)
        );
      #endif
    #else
      #if WATER_TEXTURE == 1
        block_color.rgb = mix(
          vec3(1.0),
          vec3(0.18, 0.33, 0.81),
          clamp(fresnel * .5  + WATER_TINT, 0.0, 1.0)
        ) * texture2D(tex, texcoord).a;
      #else
        block_color.rgb = mix(
          vec3(1.0),
          vec3(0.18, 0.33, 0.81),
          clamp(fresnel * .5 + WATER_TINT, 0.0, 1.0)
        );
      #endif
    #endif

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
      surface_normal,
      block_color.rgb,
      sky_color_reflect,
      reflect_water_vec,
      fresnel,
      dither
    );

  } else {  // Otros translúcidos

    #ifdef SHADOW_CASTING
      float shadow_c = get_shadow(shadow_pos);
      shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
    #else
      float shadow_c = abs((light_mix * 2.0) - 1.0);
    #endif

    vec3 real_light =
      omni_light +
      (direct_light_strenght * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
      candle_color;

    block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125);

    if (block_type > 1.5) {  // Glass
      block_color = cristal_shader(
        fragposition,
        water_normal,
        block_color,
        real_light,
        fresnel * fresnel,
        dither
        );
    }
  }

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

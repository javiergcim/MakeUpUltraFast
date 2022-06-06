/* Exits */
out vec4 outColor0;

#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform sampler2D gtexture;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
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
uniform float light_mix;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D gaux4;
uniform float alphaTestRef;

#ifdef NETHER
  uniform vec3 fogColor;
#endif

#if defined SHADOW_CASTING && !defined NETHER
  uniform sampler2DShadow shadowtex1;
  #if defined COLORED_SHADOW
    uniform sampler2DShadow shadowtex0;
    uniform sampler2D shadowcolor0;
  #endif
#endif

#ifdef CLOUD_REFLECTION
  // Don't remove (Optifine bug?)
#endif

#if defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER
  uniform vec3 cameraPosition;
  uniform mat4 gbufferModelViewInverse;
#endif

in vec2 texcoord;
in vec2 lmcoord;
in vec4 tint_color;
in float frog_adjust;
flat in vec3 water_normal;
flat in float block_type;
in vec4 worldposition;
in vec3 fragposition;
in vec3 tangent;
in vec3 binormal;
flat in vec3 direct_light_color;
in vec3 candle_color;
in float direct_light_strenght;
in vec3 omni_light;
in float visible_sky;
flat in vec3 up_vec;
in float var_fog_frag_coord;

#if defined SHADOW_CASTING && !defined NETHER
  in vec3 shadow_pos;
  in float shadow_diffuse;
#endif

#if (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
  flat in float umbral;
  flat in vec3 cloud_color;
  flat in vec3 dark_cloud_color;
#endif

#include "/lib/projection_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water.glsl"

#if defined SHADOW_CASTING && !defined NETHER
  #include "/lib/shadow_frag.glsl"
#endif

#include "/lib/luma.glsl"

#if defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER
  #include "/lib/volumetric_clouds.glsl"
#endif

void main() {
  vec4 block_color = texture(gtexture, texcoord);

  if(block_color.a < alphaTestRef) discard;  // Full transparency

  vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

  vec3 real_light;

  #ifdef VANILLA_WATER
    vec3 water_normal_base = vec3(0.0, 0.0, 1.0);
  #else
    vec3 water_normal_base = normal_waves(worldposition.xzy);
  #endif

  vec3 surface_normal = get_normals(water_normal_base, fragposition);
  vec3 flat_normal = get_normals(vec3(0.0, 0.0, 1.0), fragposition);
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
  vec3 norm_reflect_water_vec = normalize(reflect_water_vec);

  vec3 sky_color_reflect;
  if (isEyeInWater == 0 || isEyeInWater == 2) {
    sky_color_reflect = mix(
      low_sky_color,
      hi_sky_color,
      sqrt(clamp(dot(norm_reflect_water_vec, up_vec), 0.0001, 1.0))
      );
  } else {
    sky_color_reflect =
      hi_sky_color * .5 * ((eye_bright_smooth.y * .8 + 48) * 0.004166666666666667);
  }

  #if (defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER) || SSR_TYPE > 0
    #if AA_TYPE > 0
      float dither = shifted_makeup_dither(gl_FragCoord.xy);
    #else
      float dither = r_dither(gl_FragCoord.xy);
    #endif
  #else
    float dither = 1.0;
  #endif

  #if defined CLOUD_REFLECTION && (V_CLOUDS != 0 && !defined UNKNOWN_DIM) && !defined NETHER
    sky_color_reflect = get_cloud(
      normalize((gbufferModelViewInverse * vec4(reflect_water_vec * far, 1.0) ).xyz),
      sky_color_reflect,
      0.0,
      dither,
      worldposition.xyz,
      int(CLOUD_STEPS_AVG * 0.5),
      umbral,
      cloud_color,
      dark_cloud_color
    );

  #endif

  if (block_type > 2.5) {  // Water
    #ifdef VANILLA_WATER
      #if defined SHADOW_CASTING && !defined NETHER
        #if defined COLORED_SHADOW
          vec3 shadow_c = get_colored_shadow(shadow_pos);
          shadow_c = mix(shadow_c, vec3(1.0), shadow_diffuse);
        #else
          float shadow_c = get_shadow(shadow_pos);
          shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
        #endif
      #else
        float shadow_c = abs((light_mix * 2.0) - 1.0);
      #endif

      real_light =
        omni_light +
        (direct_light_strenght * shadow_c * direct_light_color) * (1.0 - rainStrength * 0.75) +
        candle_color;

      float fresnel_tex = luma(block_color.rgb);

      block_color.rgb *= mix(real_light, vec3(1.0), nightVision * .125) * tint_color.rgb;

      block_color.rgb = water_shader(
        fragposition,
        surface_normal,
        block_color.rgb,
        sky_color_reflect,
        norm_reflect_water_vec,
        fresnel * (clamp((fresnel_tex * 3.0 - 1.5), 0.0, 1.0) + 0.2),
        visible_sky,
        dither,
        direct_light_color
      );

    #else

      #if WATER_TEXTURE == 1
        float water_texture = block_color.r * 2.0;
      #else
        float water_texture = 1.0;
      #endif

      real_light =
        omni_light +
        (direct_light_strenght * direct_light_color) * (1.0 - rainStrength * 0.75) +
        candle_color;

      #if defined NETHER || defined THE_END
        #if WATER_COLOR_SOURCE == 0
          block_color.rgb = water_texture * real_light * WATER_COLOR;
        #elif WATER_COLOR_SOURCE == 1
          block_color.rgb = 0.3 * water_texture * real_light * tint_color.rgb;
        #endif
      #else
        #if WATER_COLOR_SOURCE == 0
          block_color.rgb = water_texture * real_light * visible_sky * WATER_COLOR;
        #elif WATER_COLOR_SOURCE == 1
          block_color.rgb = 0.3 * water_texture * real_light * visible_sky * tint_color.rgb;
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
        norm_reflect_water_vec,
        fresnel,
        visible_sky,
        dither,
        direct_light_color
      );

    #endif

  } else {  // Otros translúcidos

    block_color *= tint_color;

    #if defined SHADOW_CASTING && !defined NETHER
      #if defined COLORED_SHADOW
        vec3 shadow_c = get_colored_shadow(shadow_pos);
        shadow_c = mix(shadow_c, vec3(1.0), shadow_diffuse);
      #else
        float shadow_c = get_shadow(shadow_pos);
        shadow_c = mix(shadow_c, 1.0, shadow_diffuse);
      #endif
    #else
      float shadow_c = abs((light_mix * 2.0) - 1.0);
    #endif

    real_light =
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
        dither,
        direct_light_color
        );
    }
  }

  #include "/src/finalcolor.glsl"
  #include "/src/writebuffers.glsl"
}

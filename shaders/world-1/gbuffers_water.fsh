#version 120
/* MakeUp - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define WATER_F
#define NETHER
#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;
uniform float rainStrength;
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
uniform sampler2D colortex5;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;
varying vec3 water_normal;  // Flat
varying float block_type;  // Flat
varying vec4 worldposition;
varying vec4 position2;
varying vec3 tangent;
varying vec3 binormal;
varying float visible_sky;

#include "/lib/projection_utils.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water.glsl"

void main() {
  vec4 block_color;
  vec3 fragposition =
    to_screen_space(
      vec3(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z)
      );

  vec3 water_normal_base = normal_waves(worldposition.xzy);
  vec3 surface_normal = get_normals(water_normal_base);
  vec3 flat_normal = get_normals(vec3(0.0, 0.0, 1.0));
  float normal_dot_eye = dot(flat_normal, normalize(fragposition));
  float fresnel = square_pow(1.0 + normal_dot_eye);

  #if SSR_TYPE == 0
    float dither = 1.0;
  #else
    #if AA_TYPE == 0
      float dither = 2.0 + (texture_noise_64(gl_FragCoord.xy, colortex5)) * 0.2;
    #else
      float dither = 2.0 + (shifted_texture_noise_64(gl_FragCoord.xy, colortex5)) * 0.2;
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
          clamp(fresnel * .5 + WATER_TINT, 0.0, 1.0)
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

    vec3 reflect_water_vec = reflect(fragposition, surface_normal);

    block_color.rgb = water_shader(
      fragposition,
      surface_normal,
      block_color.rgb,
      gl_Fog.color.rgb * .5,
      reflect_water_vec,
      fresnel * fresnel,
      dither
    );

  } else {  // Otros translucidos

    // Toma el color puro del bloque
    block_color = texture2D(tex, texcoord);
    block_color *= tint_color * vec4(real_light, 1.0);

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

  #include "/src/writebuffers.glsl"
}

#version 130
/* MakeUp - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define WATER_F
#define NETHER
#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
in vec2 texcoord;
in vec2 lmcoord;
in vec4 tint_color;
in vec3 real_light;
flat in vec3 water_normal;
flat in float block_type;
in vec4 worldposition;
in vec4 position2;
in vec3 tangent;
in vec3 binormal;
in float visible_sky;

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

  if (block_type > 2.5) {  // Water
    #if WATER_TEXTURE == 1
      block_color.rgb = mix(
        vec3(1.0),
        tint_color.rgb,
        WATER_TINT
      ) * texture(tex, texcoord).rgb;
    #else
      block_color.rgb = mix(
        vec3(1.0),
        tint_color.rgb,
        WATER_TINT
      );
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

    vec3 surface_normal = get_normals(water_normal_base);
    vec3 reflect_water_vec = reflect(fragposition, surface_normal);

    block_color.rgb = water_shader(
      fragposition,
      // get_normals(water_normal_base),
      surface_normal,
      block_color.rgb,
      gl_Fog.color.rgb * .5,
      reflect_water_vec
    );

  } else if (block_type > 1.5) {  // Glass

    // Toma el color puro del bloque
    block_color = texture(tex, texcoord);
    block_color *= tint_color * vec4(real_light, 1.0);

    block_color = cristal_shader(
      fragposition,
      water_normal,
      block_color,
      real_light
    );

  } else if (block_type > .5){  // Portal
    block_color = texture(tex, texcoord);
    block_color *= tint_color * mix(vec4(real_light, 1.0), vec4(1.0), .2);
  } else {  // ?
    block_color = texture(tex, texcoord);
    block_color *= tint_color * vec4(real_light, 1.0);
  }

  #include "/src/writebuffers.glsl"
}

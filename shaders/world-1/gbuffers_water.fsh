#version 120
/* MakeUp Ultra Fast - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define WATER_F
#define NETHER
#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;
varying vec3 water_normal;
varying float block_type;
varying vec4 worldposition;
varying vec4 position2;
varying vec3 tangent;
varying vec3 binormal;

// 'Global' constants from system
uniform sampler2D texture;
uniform float wetness;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform sampler2D gaux2;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform float frameTimeCounter;

#include "/lib/basic_utils.glsl"
#include "/lib/dither.glsl"
#include "/lib/water.glsl"
#include "/lib/cristal.glsl"

void main() {
  vec4 block_color;
  vec3 fragposition0 =
    to_NDC(
      vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z)
      );

  if (block_type > 2.5) {  // Water
    #if TINTED_WATER == 1
      block_color.rgb = mix(
        tint_color.rgb,
        vec3(1.0),
        .4
      );
    #else
      block_color.rgb = vec3(1.0);
    #endif

    vec3 water_normal_base = waves_to_normal(worldposition.xyz);

    block_color = vec4(
      refraction(
        fragposition0,
        block_color.rgb,
        water_normal_base
      ),
      1.0
    );

    block_color.rgb = water_shader(
      fragposition0,
      get_normals(water_normal_base),
      block_color.rgb,
      gl_Fog.color.rgb * .5
    );

  } else if (block_type > 1.5) {  // Glass

    // Toma el color puro del bloque
    block_color = texture2D(texture, texcoord);
    block_color *= tint_color * vec4(real_light, 1.0);

    block_color = cristal_shader(
      fragposition0,
      water_normal,
      block_color,
      real_light
    );

  } else if (block_type > .5){  // Portal
    block_color = texture2D(texture, texcoord);
    block_color *= tint_color * mix(vec4(real_light, 1.0), vec4(1.0), .2);
  } else {  // ?
    block_color = texture2D(texture, texcoord);
    block_color *= tint_color * vec4(real_light, 1.0);
  }

  #include "/src/writebuffers.glsl"
}

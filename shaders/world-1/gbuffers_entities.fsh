#version 400 compatibility
/* MakeUp Ultra Fast - gbuffers_entities.fsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform sampler2D tex;
uniform int entityId;
uniform vec4 entityColor;

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;

void main() {
  // Toma el color puro del bloque
  // vec4 block_color = texture(tex, texcoord) * tint_color;
  vec4 block_color = texture(tex, texcoord);
  if (block_color.a < 0.1) {   // Blacl entities bug workaround
    discard;
  }
  block_color *= tint_color;

  // Thunderbolt render
  if (entityId == 11000.0){
    block_color = vec4(1.0, 1.0, 1.0, .8);
  }

  block_color *= tint_color * vec4(real_light, 1.0);
  block_color.rgb = mix(block_color.rgb, entityColor.rgb, entityColor.a * .75);

  #include "/src/writebuffers.glsl"
}

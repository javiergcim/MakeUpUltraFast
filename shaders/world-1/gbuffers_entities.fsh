#version 130
/* MakeUp Ultra Fast - gbuffers_entities.fsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying vec3 real_light;

// 'Global' constants from system
uniform sampler2D tex;
uniform int entityId;

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture(tex, texcoord);

  // Thunderbolt render
  if (entityId == 11000.0){
    block_color = vec4(1.0, 1.0, 1.0, .8);
  }

  block_color *= tint_color * vec4(real_light, 1.0);

  #include "/src/writebuffers.glsl"
}

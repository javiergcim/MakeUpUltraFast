#version 120
/* MakeUp Ultra Fast - deferred.fsh
Render: Used for ambient occlusion

Javier Garduño - GNU Lesser General Public License v3.0
*/

#include "/lib/config.glsl"

// Varyings (per thread shared variables)
varying vec2 texcoord;

// 'Global' constants from system
uniform sampler2D texture;
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform float aspectRatio;
uniform mat4 gbufferProjection;
uniform float frameTimeCounter;

#include "/lib/dither.glsl"
#include "/lib/depth.glsl"
#include "/lib/ao.glsl"

void main() {
  // Toma el color puro del bloque
  vec4 block_color = texture2D(texture, texcoord);

  #if AO == 1
    #if TAA == 1
      float dither = time_hash12();
    #else
      float dither = hash12();
    #endif

    // AO distance attenuation
    float d = texture2D(depthtex0, texcoord.xy).r;
    float ao_att = sqrt(ld(d));
    float final_ao = mix(dbao(depthtex0, dither), 1.0, ao_att);
    block_color *= final_ao;
    // block_color = vec4(vec3(final_ao), 1.0);
  #endif

  #include "/src/writebuffers.glsl"
}

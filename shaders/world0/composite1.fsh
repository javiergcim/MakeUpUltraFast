#version 130
/* MakeUp Ultra Fast - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex5;
uniform sampler2D colortex7;
uniform float frameTimeCounter;
uniform float inv_aspect_ratio;
uniform float viewHeight;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/dither.glsl"
#include "/lib/bloom.glsl"

void main() {
  vec4 block_color = texture(colortex1, texcoord);

  #if BLOOM == 1
    vec3 bloom = noised_bloom(colortex7, texcoord);
    // vec3 suma = block_color.rgb + (bloom * 0.1);
    /* DRAWBUFFERS:01 */
    gl_FragData[1] = vec4(block_color.rgb + (bloom * 0.1), block_color.a);
  #else
    gl_FragData[1] = block_color;
  #endif
}

#version 130
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex5;
uniform sampler2D colortex2;
uniform float frameTimeCounter;
uniform float inv_aspect_ratio;

// Varyings (per thread shared variables)
varying vec2 texcoord;

#include "/lib/dither.glsl"
#include "/lib/bloom.glsl"

#if BLOOM == 1
  const bool colortex2MipmapEnabled = true;
#endif

void main() {
  vec4 block_color = texture(colortex1, texcoord);

  #if BLOOM == 1
    vec3 bloom = mipmap_bloom(colortex2, texcoord);

    /* DRAWBUFFERS:01 */
    gl_FragData[1] = vec4(block_color.rgb + bloom, block_color.a);
    // gl_FragData[1] = vec4(bloom * 10.0, block_color.a);
  #else
    /* DRAWBUFFERS:013 */
    gl_FragData[1] = block_color;
  #endif
}

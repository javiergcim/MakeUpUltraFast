#version 120
/* MakeUp - final.fsh
Render: Bloom

Javier Garduño - GNU Lesser General Public License v3.0
*/

// #define NO_SHADOWS

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

#ifdef BLOOM
  const bool colortex2MipmapEnabled = true;
#endif

// GODRAY START
  uniform mat4 gbufferProjectionInverse;
  uniform mat4 gbufferModelViewInverse;
  uniform mat4 shadowModelView;
  uniform mat4 shadowProjection;
  uniform float viewWidth;
  uniform float viewHeight;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
  uniform float near;
  uniform float far;
  uniform sampler2DShadow shadowtex1;
  uniform sampler2D depthtex0;
  #include "/lib/depth.glsl"
  #include "/lib/shadow_frag.glsl"
  #include "/lib/volumetric_light.glsl"
// GODRAY END

void main() {
  vec4 block_color = texture2D(colortex1, texcoord);

#ifdef BLOOM
  vec3 bloom = mipmap_bloom(colortex2, texcoord);
  block_color.rgb += bloom;
#endif

// GODRAY START
float dither = timed_hash12(gl_FragCoord.xy);
float screen_depth = texture2D(depthtex0, texcoord).r;
screen_depth = ld(screen_depth);

float light = get_volumetric_light(dither, screen_depth);

block_color.rgb = vec3(light);
// block_color.rgb = vec3(screen_depth);
// block_color.rgb = vec3(texcoord, screen_depth);
// GODRAY END

  #ifdef MOTION_BLUR
    #ifdef DOF
      /* DRAWBUFFERS:01 */
      gl_FragData[0] = block_color;
      gl_FragData[1] = block_color;
    #else
      /* DRAWBUFFERS:1 */
      gl_FragData[0] = block_color;
    #endif
  #else
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
  #endif
}

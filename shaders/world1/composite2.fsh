#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Horizontal blur pass

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define THE_END
#define NO_SHADOWS

#include "/lib/config.glsl"

#if DOF == 1
  uniform sampler2D depthtex1;
  uniform float centerDepthSmooth;
  uniform sampler2D colortex4;
  uniform float pixel_size_x;
  uniform float viewWidth;
#else
  uniform sampler2D colortex0;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  #include "/lib/blur.glsl"
#endif

void main() {

  #if DOF == 1
    float the_depth = texture2D(depthtex1, texcoord).r;
    float blur_radius = 0.0;
    if (the_depth > 0.56) {
      blur_radius =
        max(abs(the_depth - centerDepthSmooth) - 0.0001, 0.0);
      blur_radius = blur_radius / sqrt(0.1 + blur_radius * blur_radius) * DOF_STRENGTH;
      blur_radius = min(blur_radius, 0.02);
    }

    vec3 color = texture2D(colortex4, texcoord).rgb;

    if (blur_radius > pixel_size_x) {
      float radius_inv = 1.0 / blur_radius;
      float weight;
      vec4 new_blur;

      vec4 average = vec4(0.0);
      float start  = max(texcoord.x - blur_radius, pixel_size_x * 0.5);
      float finish = min(texcoord.x + blur_radius, 1.0 - pixel_size_x * 0.5);
      float step = pixel_size_x;
      if (blur_radius > (6.0 * pixel_size_x)) {
        step *= 3.0;
      } else if (blur_radius > 2.0 * pixel_size_x) {
        step *= 2.0;
      }

      for (float x = start; x <= finish; x += step) {  // Blur samples
        weight = fogify((x - texcoord.x) * radius_inv, 0.35);
        new_blur = texture2D(colortex4, vec2(x, texcoord.y));
        average.rgb += new_blur.rgb * weight;
        average.a += weight;
      }
      color = average.rgb / average.a;
    }
  #else
    vec3 color = texture2D(colortex0, texcoord).rgb;
  #endif

  #if DOF == 1
    gl_FragData[4] = vec4(color, blur_radius);
  #else
    gl_FragData[0] = vec4(color, 1.0);
  #endif
}

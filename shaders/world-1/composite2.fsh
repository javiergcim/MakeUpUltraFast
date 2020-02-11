#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Horizontal blur pass

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define DOF 1  // [0 1] Enables depth of field

// 'Global' constants from system
uniform sampler2D colortex0;

#if DOF == 1
  uniform sampler2D gaux1;
  uniform float pixelSizeX;
  uniform float viewWidth;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  // varying float dofDistance;
  #include "/lib/blur.glsl"
#endif

void main() {
  vec4 color = texture2D(colortex0, texcoord);

  #if DOF == 1
    float blur_radius = texture2D(gaux1, texcoord).r;

    if (blur_radius > 0.0) {
      float radius_inv = 1.0 / blur_radius;

      vec4 average = vec4(0.0);
      float start  = max(texcoord.x - blur_radius * pixelSizeX,       pixelSizeX * 0.5);
      float finish = min(texcoord.x + blur_radius * pixelSizeX, 1.0 - pixelSizeX * 0.5);
      float step = pixelSizeX * .5;
      if (blur_radius > 2.0) {
        step *= 4.0;
      } else if (blur_radius > 1.0) {
        step *= 1.0;
      }

      for (float x = start; x <= finish; x += step) {  // step
        float weight = fogify((x - texcoord.x) * viewWidth * radius_inv, 0.25);
        vec4 newColor = texture2D(colortex0, vec2(x, texcoord.y));
        float new_blur = texture2D(gaux1, vec2(x, texcoord.y)).r;
        weight *= new_blur * radius_inv;
        average.rgb += newColor.rgb * weight;
        average.a += weight;
      }
      color.rgb = average.rgb / average.a;
    }
  #endif

  #if DOF == 1
    gl_FragData[4] = vec4(blur_radius);
    gl_FragData[5] = color;
  #else
    gl_FragData[0] = color;
  #endif
  gl_FragData[1] = vec4(0.0);  // ¿Performance?
}

#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Horizontal blur pass

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define DOF 0  // [0 1] Enables depth of field
#define DOF_STRENGTH 2  // [2 3 4 5 6 7 8 9 10 11 12 13 14]  Depth of field streght

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
    float blur = texture2D(gaux1, texcoord).r;

    if (blur > 0.0) {
      float invblur_radius1 = 1.0 / blur;
    	float blur_radius = blur * 256.0; //actual radius in pixels
    	float invblur_radius2 = 1.0 / blur_radius;

    	vec4 average = vec4(0.0);
    	float start  = max(texcoord.x - blur_radius * pixelSizeX,       pixelSizeX * 0.5);
    	float finish = min(texcoord.x + blur_radius * pixelSizeX, 1.0 - pixelSizeX * 0.5);
    	float step   = max(pixelSizeX * 0.5, blur_radius * pixelSizeX / float(DOF_STRENGTH));

    	for (float x = start; x <= finish; x += step) {
    	 	float weight = fogify(((texcoord.x - x) * viewWidth) * invblur_radius2, 0.35);
    	 	vec4 newColor = texture2D(colortex0, vec2(x, texcoord.y));
        float new_blur = texture2D(gaux1, vec2(x, texcoord.y)).r;
    	 	weight *= new_blur * invblur_radius1;
    	 	average.rgb += newColor.rgb * newColor.rgb * weight;
    	 	average.a += weight;
    	}
    	color.rgb = sqrt(average.rgb / average.a);
    }
  #endif


  #if DOF == 1
    gl_FragData[4] = vec4(blur);
    gl_FragData[5] = color;
  #else
    gl_FragData[0] = color;
  #endif
  gl_FragData[1] = vec4(0.0);  // ¿Performance?
}

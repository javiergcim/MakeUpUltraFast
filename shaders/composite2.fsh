#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Composite after gbuffers

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define DOF 1  // [0 1] Enables depth of field
#define BLUR_QUALITY 10

#include "/lib/globals.glsl"

// 'Global' constants from system
uniform sampler2D G_COLOR;

#if DOF == 1
  uniform sampler2D gaux1;
  uniform sampler2D gaux2;
  uniform float pixelSizeY;
  uniform float viewHeight;
  uniform float pixelSizeX;
  uniform float viewWeight;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;

#if DOF == 1
  // varying float dofDistance;
  #include "/lib/blur.glsl"
#endif

void main() {

  #if DOF == 1
    vec4 color = texture2D(gaux2, texcoord);
    float blur_radius = texture2D(gaux1, texcoord).r;
    //
    if (blur_radius > 0.0) {
      float invblur_radius1 = 1.0 / blur_radius;
    	blur_radius *= 256.0; //actual radius in pixels
    	float invblur_radius2 = 1.0 / blur_radius;

    	vec4 average = vec4(0.0);
    	float start  = max(texcoord.y - blur_radius * pixelSizeY,       pixelSizeY * 0.5);
    	float finish = min(texcoord.y + blur_radius * pixelSizeY, 1.0 - pixelSizeY * 0.5);
    	float step   = max(pixelSizeY * 0.5, blur_radius * pixelSizeY / float(BLUR_QUALITY));

    	for (float y = start; y <= finish; y += step) {
    	 	float weight = fogify(((texcoord.y - y) * viewHeight) * invblur_radius2, 0.35);
    	 	vec4 newColor = texture2D(gaux2, vec2(texcoord.x, y));
        float new_blur = texture2D(gaux1, vec2(texcoord.x, y)).r;
    	 	weight *= new_blur * invblur_radius1;
    	 	average.rgb += newColor.rgb * newColor.rgb * weight;
    	 	average.a += weight;
    	}
    	color.rgb = sqrt(average.rgb / average.a);
    }

    gl_FragData[0] = color;
    // gl_FragData[0] = vec4(vec3((blur_radius * 256) / 10.0), 1.0);

  #else
    gl_FragData[0] = texture2D(G_COLOR, texcoord);
  #endif
}

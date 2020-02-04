#version 120
/* MakeUp Ultra Fast - composite.fsh
Render: Vertical blur pass and final renderer

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Do not remove ¡It works!
/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = R8;
const int colortex2Format = R8;
const int colortex3Format = R8;
const int gaux1Format = R16F;
const int gaux2Format = RGB8;
const int colortex6Format = R8;
const int colortex7Format = R8;

const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool colortex4Clear = false;
const bool colortex5Clear = false;
*/


// Redefined constants
const int noiseTextureResolution = 128;
const float ambientOcclusionLevel = 1.0f;
const float eyeBrightnessHalflife = 10.0f;

#define DOF 0  // [0 1] Enables depth of field
#define DOF_STRENGTH 2  // [2 3 4 5 6 7 8 9 10 11 12 13 14]  Depth of field streght

// 'Global' constants from system
uniform sampler2D colortex0;

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
    float blur_demo = blur_radius;

    if (blur_radius > 0.0) {
      float invblur_radius1 = 1.0 / blur_radius;
    	blur_radius *= 256.0; //actual radius in pixels
    	float invblur_radius2 = 1.0 / blur_radius;

    	vec4 average = vec4(0.0);
    	float start  = max(texcoord.y - blur_radius * pixelSizeY,       pixelSizeY * 0.5);
    	float finish = min(texcoord.y + blur_radius * pixelSizeY, 1.0 - pixelSizeY * 0.5);
    	float step   = max(pixelSizeY * 0.5, blur_radius * pixelSizeY / float(DOF_STRENGTH));

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

    gl_FragColor = color;

  #else
    gl_FragColor = texture2D(colortex0, texcoord);
  #endif
}

#version 120
/* MakeUp Ultra Fast - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

// #extension GL_EXT_gpu_shader4 : enable
// #extension GL_ARB_shader_texture_lod : enable

#define NICE_WATER 1 // [0 1] Turn on for reflection and refraction capabilities.
#define TINTED_WATER 1 // [0 1] Use the resource pack color for water.
#define REFLECTION 1 // [0 1] Activate reflectons
#define REFRACTION 1 // [0 1] Activate refractions
#define SSR_METHOD 0 // [0 1] Select reflection method

const int noiseTextureResolution  = 128;

#include "/lib/globals.glsl"
#include "/lib/color_utils.glsl"

// Varyings (per thread shared variables)
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec4 tint_color;
varying vec3 my_normal;
varying vec4 normal;
varying vec3 sun_vec;
varying vec3 moon_vec;
varying float iswater;
varying float istranslucent;
varying vec4 position2;
varying vec4 worldposition;
varying vec3 tangent;
varying vec3 binormal;

// 'Global' constants from system
uniform int worldTime;
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform int isEyeInWater;
uniform int entityId;
uniform float nightVision;
uniform float rainStrength;
uniform float wetness;
uniform float near;
uniform float far;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform sampler2D noisetex;
uniform float sunAngle;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform sampler2D composite;
uniform sampler2D gaux2;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform vec3 sunPosition;

// Code start -----------------

float waterWaves(vec3 worldPos) {
  float wave = 0.0;

  worldPos.z += worldPos.y;
	worldPos.x += worldPos.y;

  worldPos.z *= 0.5;
  worldPos.x += sin(worldPos.x) * 0.3;

  // Defined as: mat2 rotate_mat = mat2(cos(.5), -sin(.5), sin(.5), cos(.5));
  const mat2 rotate_mat = mat2(0.8775825618903728, -0.479425538604203,
                         -0.479425538604203, 0.8775825618903728);

  wave = texture2D(noisetex, worldPos.xz * 0.075 + vec2(frameTimeCounter * 0.015)).x * 0.1;
	wave += texture2D(noisetex, worldPos.xz * 0.02 - vec2(frameTimeCounter * 0.0075)).x * 0.5;
  wave += texture2D(noisetex, worldPos.xz * 0.02 * rotate_mat + vec2(frameTimeCounter * 0.0075)).x * 0.5;

  return wave * 0.1;
}

vec3 waterwavesToNormal(vec3 pos) {
  float deltaPos = 0.1;
	float h0 = waterWaves(pos.xyz);
	float h1 = waterWaves(pos.xyz + vec3(deltaPos, 0.0, 0.0));
	float h2 = waterWaves(pos.xyz + vec3(-deltaPos, 0.0, 0.0));
	float h3 = waterWaves(pos.xyz + vec3(0.0, 0.0, deltaPos));
	float h4 = waterWaves(pos.xyz + vec3(0.0, 0.0, -deltaPos));

	float xDelta = ( (h1 - h0) + (h0 - h2) ) / deltaPos;
	float yDelta = ( (h3 - h0) + (h0 - h4) ) / deltaPos;

	// return normalize(vec3(xDelta, yDelta, 1.0 - xDelta * xDelta - yDelta * yDelta)); // Original
  return vec3(xDelta, yDelta, 1.0 - xDelta * xDelta - yDelta * yDelta);
}

vec3 toNDC(vec3 pos){
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2. - 1.;
    vec4 fragpos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

vec3 cameraSpaceToScreenSpace(vec3 fragpos) {
	vec4 pos  = gbufferProjection * vec4(fragpos, 1.0);
			 pos /= pos.w;

	return pos.xyz * 0.5 + 0.5;
}

vec3 cameraSpaceToWorldSpace(vec3 fragpos) {
	vec4 pos  = gbufferProjectionInverse * vec4(fragpos, 1.0);
			 pos /= pos.w;

	return pos.xyz;

}

vec3 refraction(vec3 fragpos, vec3 color, vec3 waterRefract) {
  vec3 pos = cameraSpaceToScreenSpace(fragpos);

  #if REFRACTION == 1

    float	waterRefractionStrength = 0.1;
    waterRefractionStrength /= 1.0 + length(fragpos) * 0.4;
    vec2 waterTexcoord = pos.xy + waterRefract.xy * waterRefractionStrength;

    return texture2D(gaux2, waterTexcoord.st).rgb * color;

  #else

    return texture2D(gaux2, pos.xy).rgb * color;

  #endif

}

vec3 getNormals(vec3 bump) {
	float NdotE = abs(dot(normal.xyz, normalize(position2.xyz)));

	bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
						  					tangent.y, binormal.y, normal.y,
						  					tangent.z, binormal.z, normal.z);

	return normalize(bump * tbnMatrix);
}

float ditherGradNoise() {
  return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y));
}

float cdist(vec2 coord) {
	return max(abs(coord.s - 0.5), abs(coord.t - 0.5)) * 2.0;
}

vec4 raytrace(vec3 fragpos, vec3 normal) {

	#if SSR_METHOD == 0

    vec3 reflectedVector = reflect(normalize(fragpos), normal) * 30.0;
    vec3 pos = cameraSpaceToScreenSpace(fragpos + reflectedVector);

    float border = clamp((1.0 - (max(0.0, abs(pos.t - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

		return vec4(texture2D(gaux2, pos.xy, 0.0).rgb, border);

	#else

		float dither    = ditherGradNoise();

		const int samples       = 10;
		// const int samples       = 28;
		const int maxRefinement = 10;
		const float stepSize    = 1.2;
		const float stepRefine  = 0.28;
		const float stepIncrease = 1.8;

		vec3 col        = vec3(0.0);
		vec3 rayStart   = fragpos;
		vec3 rayDir     = reflect(normalize(fragpos), normal);
		vec3 rayStep    = (stepSize+dither-0.5)*rayDir;
		vec3 rayPos     = rayStart + rayStep;
		vec3 rayPrevPos = rayStart;
		vec3 rayRefine  = rayStep;

		int refine  = 0;
		vec3 pos    = vec3(0.0);
		float border = 0.0;

		for (int i = 0; i < samples; i++) {

			pos = cameraSpaceToScreenSpace(rayPos);

			if (pos.x<0.0 || pos.x>1.0 || pos.y<0.0 || pos.y>1.0 || pos.z<0.0 || pos.z>1.0) break;

			vec3 screenPos  = vec3(pos.xy, texture2D(depthtex1, pos.xy).x);
					 screenPos  = cameraSpaceToWorldSpace(screenPos * 2.0 - 1.0);

			float dist = distance(rayPos, screenPos);

			if (dist < pow(length(rayStep)*pow(length(rayRefine), 0.11), 1.1)*1.22) {

				refine++;
				if (refine >= maxRefinement)	break;

				rayRefine  -= rayStep;
				rayStep    *= stepRefine;

			}

			rayStep        *= stepIncrease;
			rayPrevPos      = rayPos;
			rayRefine      += rayStep;
			rayPos          = rayStart+rayRefine;

		}

		if (pos.z < 1.0-1e-5) {
			float depth = texture2D(depthtex0, pos.xy).x;

			float comp = 1.0 - near / far / far;
			bool land = depth < comp;

			if (land) {
				col = texture2D(gaux2, pos.xy).rgb;
				border = clamp((1.0 - cdist(pos.st)) * 50.0, 0.0, 1.0);
			}
		}

		return vec4(col, border);

	#endif

}

vec3 waterShader(vec3 fragpos, vec3 normal, vec3 color, float shading, vec3 skyReflection) {

  vec3 reflectedVector = reflect(normalize(fragpos), normal) * 300.0;

	vec4 reflection = vec4(0.0);
	#if REFLECTION == 1
		reflection = raytrace(fragpos, normal);
	#endif

	float normalDotEye = dot(normal.rgb, normalize(fragpos));
	float fresnel = clamp(pow(1.0 + normalDotEye, 4.0) + 0.1, 0.0, 1.0);

	reflection.rgb = mix(skyReflection * pow(lmcoord.t, 2.0), reflection.rgb, reflection.a);

  return mix(color, reflection.rgb, fresnel);
}

void main() {
  // Custom light (lmcoord.x: candle, lmcoord.y: ambient) ----
  vec2 illumination = lmcoord.xy;
  // Tomamos el color de ambiente con base a la hora
  float current_hour = worldTime / 1000.0;
  vec3 ambient_currentlight =
    mix(
      ambient_baselight[int(floor(current_hour))],
      ambient_baselight[int(ceil(current_hour))],
      fract(current_hour)
    ) * ambient_multiplier;

  illumination.y = pow(illumination.y, 3);  // Non-linear decay
  illumination.y = (illumination.y * .99) + .01;  // Avoid absolute dark

  // Ajuste de intensidad luminosa bajo el agua
  if (isEyeInWater == 1.0) {
    illumination.y = (illumination.y * .95) + .05;
  }

  vec3 ambient_color =
    ambient_currentlight * illumination.y;
  vec3 candle_color =
    candle_baselight * pow(illumination.x, 4);  // Non-linear decay

  // Se ajusta luz ambiental en tormenta
  ambient_color = ambient_color * (1.0 - (rainStrength * .4));

  vec3 real_light =
    mix(ambient_color + candle_color, vec3(1.0), nightVision * .125);

  // Indica cuanta iluminación basada en dirección de fuente de luz se usará
  float direct_light_coefficient = clamp(lmcoord.y * 2.0 - 1.0, 0.0, 1.0);
  float direct_light_strenght = 1.0;

   // Si no estamos ocultos al cielo calculamos iluminación de dirección
  if (direct_light_coefficient > 0.0) {
    if ((worldTime >= 0 && worldTime <= 12700) || worldTime > 23000) {  // Día
      direct_light_strenght = dot(my_normal, sun_vec);
    //
    } else if (worldTime > 12700 && worldTime <= 13400 ) { // Anochece
      float sun_light_strenght = dot(my_normal, sun_vec);
      float moon_light_strenght = dot(my_normal, moon_vec);
      float light_mix = (worldTime - 12700) / 700.0;
      // Calculamos la cantidad de mezcla de luz de sol y luna
      direct_light_strenght =
        mix(sun_light_strenght, moon_light_strenght, light_mix);

    } else if (worldTime > 13400 && worldTime <= 22300) {  // Noche
      direct_light_strenght = dot(my_normal, moon_vec);

    } else if (worldTime > 22300) {  // Amanece
      float sun_light_strenght = dot(my_normal, sun_vec);
      float moon_light_strenght = dot(my_normal, moon_vec);
      float light_mix = (worldTime - 22300) / 700.0;
      // Calculamos la cantiidad de mezcla de luz de sol y luna
      direct_light_strenght =
        mix(moon_light_strenght, sun_light_strenght, light_mix);
    }

    // Escalamos para evitar negros en zonas oscuras
    direct_light_strenght = direct_light_strenght * .4 + .6;
    direct_light_strenght =
      mix(1.0, direct_light_strenght, direct_light_coefficient);
  }

  // Prepare Sky/Fog color calculation
  float fog_mix_level = mix(
    fog_color_mix[int(floor(current_hour))],
    fog_color_mix[int(ceil(current_hour))],
    fract(current_hour)
    );
    // Fog color calculation
  vec3 current_fog_color = mix(skyColor, gl_Fog.color.rgb, fog_mix_level);

  // Begin water code ---------------

  vec4 block_color;

  if (iswater > .5) {

    #if NICE_WATER == 1

      #if TINTED_WATER == 1
        // block_color.rgb = tint_color.rgb * real_light * direct_light_strenght;
        block_color.rgb = tint_color.rgb * direct_light_strenght;
      #else
        block_color.rgb = vec3(1.0);
      #endif

      vec3 water_normal_base = waterwavesToNormal(worldposition.xyz);

      vec3 fragposition0 = toNDC(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z));

      block_color = vec4(
  			refraction(
  				fragposition0,
  				block_color.rgb,
  				water_normal_base
  			),
  			1.0
  		);

      block_color.rgb = waterShader(
        fragposition0.xyz,
        getNormals(water_normal_base),
        block_color.rgb,
        lmcoord.y > 0.9? 1.0 : 0.0,
        current_fog_color
      );

    #else
      // Toma el color puro del bloque
      block_color = texture2D(texture, texcoord.xy);
      // Se agrega mapa de color y sombreado nativo
      block_color *= (tint_color * vec4(real_light, 1.0));
      // Iluminación propia
      block_color.rgb *= direct_light_strenght;
      block_color.a = .66;
    #endif

  } else {  // End water shader code ------------------------
    // Toma el color puro del bloque
    block_color = texture2D(texture, texcoord.xy);
    // Se agrega mapa de color y sombreado nativo
    block_color *= (tint_color * vec4(real_light, 1.0));
    // Iluminación propia
    block_color.rgb *= direct_light_strenght;
  }

  // Posproceso de la niebla
  if (isEyeInWater == 1.0) {
		block_color.rgb =
      mix(
        block_color.rgb,
        waterfog_baselight * real_light,
        1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0)
      );
  } else if (isEyeInWater == 2.0) {
    block_color.rgb =
      mix(
        block_color.rgb,
        gl_Fog.color.rgb * real_light,
        1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0)
      );
	} else {
    // Fog intensity calculation
    float fog_intensity_coeff = mix(
      fog_density[int(floor(current_hour))],
      fog_density[int(ceil(current_hour))],
      fract(current_hour)
      );
    fog_intensity_coeff = max(fog_intensity_coeff, wetness);
    float new_frog = (((gl_FogFragCoord / far) * (2.0 - fog_intensity_coeff)) - (1.0 - fog_intensity_coeff)) * far;
    float frog_adjust = new_frog / far;

    block_color.rgb =
      mix(
        block_color.rgb,
        current_fog_color,
        pow(clamp(frog_adjust, 0.0, 1.0), 2)
      );
  }

  gl_FragData[0] = block_color;
  gl_FragData[4] = vec4(0.0);
	// gl_FragData[1] = vec4(0.0);  // Not needed. Performance trick
}

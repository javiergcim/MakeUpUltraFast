#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

vec3 toScreenSpace(vec3 p) {
  vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
  vec3 p3 = p * 2.0 - 1.0;
  vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
  return fragposition.xyz / fragposition.w;
}

vec3 toClipSpace3Prev(vec3 viewSpacePosition) {
    return projMAD(gbufferPreviousProjection, viewSpacePosition) / -viewSpacePosition.z * 0.5 + 0.5;
}

vec3 fast_taa(vec3 c) {
  // Reproyección del cadro anterior
  vec3 closestToCamera = vec3(texcoord, texture2D(depthtex0, texcoord).x);
  vec3 fragposition = toScreenSpace(closestToCamera);
  fragposition = mat3(gbufferModelViewInverse) * fragposition + gbufferModelViewInverse[3].xyz + (cameraPosition - previousCameraPosition);
  vec3 previousPosition = mat3(gbufferPreviousModelView) * fragposition + gbufferPreviousModelView[3].xyz;
  previousPosition = toClipSpace3Prev(previousPosition);
  previousPosition.xy = texcoord + (previousPosition.xy - closestToCamera.xy);
  vec2 histUv = previousPosition.xy;

  // Verificamos si proyección queda fuera de la pantalla actual
  bvec2 a = greaterThan(histUv, vec2(1.0));
  bvec2 b = lessThan(histUv, vec2(0.0));

  float blend = any(bvec2(any(a), any(b))) ? 0.0 : 0.85;

  if (blend < 0.5) {
    return c;
  } else {
    vec3 neighbourhood[9];

    neighbourhood[0] = texture2D(colortex0, texcoord + vec2(-pixelSizeX, -pixelSizeY)).xyz;
    neighbourhood[1] = texture2D(colortex0, texcoord + vec2(0.0, -pixelSizeY)).xyz;
    neighbourhood[2] = texture2D(colortex0, texcoord + vec2(pixelSizeX, -pixelSizeY)).xyz;
    neighbourhood[3] = texture2D(colortex0, texcoord + vec2(-pixelSizeX, 0.0)).xyz;
    neighbourhood[4] = texture2D(colortex0, texcoord).xyz;
    neighbourhood[4] = c;
    neighbourhood[5] = texture2D(colortex0, texcoord + vec2(pixelSizeX, 0.0)).xyz;
    neighbourhood[6] = texture2D(colortex0, texcoord + vec2(-pixelSizeX, pixelSizeY)).xyz;
    neighbourhood[7] = texture2D(colortex0, texcoord + vec2(0.0, pixelSizeY)).xyz;
    neighbourhood[8] = texture2D(colortex0, texcoord + vec2(pixelSizeX, pixelSizeY)).xyz;

    vec3 nmin = neighbourhood[0];
    vec3 nmax = neighbourhood[0];
    for(int i = 1; i < 9; ++i) {
      nmin = min(nmin, neighbourhood[i]);
      nmax = max(nmax, neighbourhood[i]);
    }

    // Muestra del pasado
		vec3 previous = texture2D(colortex3, histUv).xyz;

		// Verificamos si muestra sale del rango dado por la vecindad
	  // bvec3 cmax = greaterThan(previous, mix(nmax, vec3(1.0), .75));
	  // bvec3 dmin = lessThan(previous, mix(nmax, vec3(0.0), .75));
		//
	  // blend = any(bvec2(any(cmax), any(dmin))) ? 1.0 : 0.15;

		// Ajustamos mezcla según distancia
		// float dist = distance(c, previous) * 0.5773502691896258;
		// blend = mix(blend, 1.0, dist);

    vec3 histSample = clamp(previous, nmin, nmax);

		vec2 velocity = (texcoord - histUv) * vec2(viewWidth, viewHeight);
		blend = exp(-length(velocity)) * 0.6 + 0.3;

		// Ghosting
		float luma_p = dot(previous, vec3(0.21, 0.72, 0.07));
		float clamped = distance(previous, histSample) / luma_p;

    // Se regresa la mezcla del pasado con el presente
    return mix(c, histSample, clamp(blend - clamped, 0.0, 1.0));
		// return mix(c, histSample, blend);
  }
}

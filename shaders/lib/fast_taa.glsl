#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

vec3 to_screen_space(vec3 p) {
  vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
  vec3 p3 = p * 2.0 - 1.0;
  vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
  return fragposition.xyz / fragposition.w;
}

vec3 toClipSpace3Prev(vec3 viewSpacePosition) {
    return projMAD(gbufferPreviousProjection, viewSpacePosition) / -viewSpacePosition.z * 0.5 + 0.5;
}

vec3 fast_taa(vec3 current_color, vec2 texcoord_past, vec2 velocity) {
  // Reproyección del cuadro anterior
  // vec3 closest_to_camera = vec3(texcoord, texture2D(depthtex0, texcoord).x);
  // vec3 fragposition = to_screen_space(closest_to_camera);
  // fragposition = mat3(gbufferModelViewInverse) * fragposition + gbufferModelViewInverse[3].xyz + (cameraPosition - previousCameraPosition);
  // vec3 previous_position = mat3(gbufferPreviousModelView) * fragposition + gbufferPreviousModelView[3].xyz;
  // previous_position = toClipSpace3Prev(previous_position);
  // previous_position.xy = texcoord + (previous_position.xy - closest_to_camera.xy);
  // vec2 texcoord_past = previous_position.xy;

  // Verificamos si proyección queda fuera de la pantalla actual
  bvec2 a = greaterThan(texcoord_past, vec2(1.0));
  bvec2 b = lessThan(texcoord_past, vec2(0.0));

  if (any(bvec2(any(a), any(b)))) {
    return current_color;
  } else {
    vec3 neighbourhood[9];

    neighbourhood[0] = texture2D(colortex2, texcoord + vec2(-pixelSizeX, -pixelSizeY)).xyz;
    neighbourhood[1] = texture2D(colortex2, texcoord + vec2(0.0, -pixelSizeY)).xyz;
    neighbourhood[2] = texture2D(colortex2, texcoord + vec2(pixelSizeX, -pixelSizeY)).xyz;
    neighbourhood[3] = texture2D(colortex2, texcoord + vec2(-pixelSizeX, 0.0)).xyz;
    neighbourhood[4] = current_color;
    neighbourhood[5] = texture2D(colortex2, texcoord + vec2(pixelSizeX, 0.0)).xyz;
    neighbourhood[6] = texture2D(colortex2, texcoord + vec2(-pixelSizeX, pixelSizeY)).xyz;
    neighbourhood[7] = texture2D(colortex2, texcoord + vec2(0.0, pixelSizeY)).xyz;
    neighbourhood[8] = texture2D(colortex2, texcoord + vec2(pixelSizeX, pixelSizeY)).xyz;

    vec3 nmin = neighbourhood[0];
    vec3 nmax = nmin;
    for(int i = 1; i < 9; ++i) {
      nmin = min(nmin, neighbourhood[i]);
      nmax = max(nmax, neighbourhood[i]);
    }

    // Muestra del pasado
    vec3 previous = texture2D(colortex3, texcoord_past).xyz;
    vec3 past_sample = clamp(previous, nmin, nmax);

    // Reducción de ghosting por velocidad
    // vec2 velocity = (texcoord - texcoord_past) * vec2(viewWidth, viewHeight);
    float blend = exp(-length(velocity)) * 0.35 + 0.6;

    // Reducción de ghosting por luma
    float luma_p = luma(previous);
    float clamped = distance(previous, past_sample) / luma_p;

    return mix(current_color, past_sample, clamp(blend - clamped, 0.0, 1.0));
  }
}

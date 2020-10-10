vec3 fast_taa(vec3 current_color, vec2 texcoord_past, vec2 velocity) {
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
    // float blend = exp(-length(velocity * vec2(viewWidth, viewHeight))) * 0.35 + 0.6;
    float blend = exp(-length(velocity * vec2(viewWidth, viewHeight))) * 0.3 + 0.6;

    // Reducción de ghosting por luma
    float luma_p = luma(previous);
    float clamped = distance(previous, past_sample) / luma_p;

    return mix(current_color, past_sample, clamp(blend - clamped, 0.0, 1.0));
  }
}

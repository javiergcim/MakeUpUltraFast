vec3 fast_taa(vec3 current_color, vec2 texcoord_past, vec2 velocity) {
  // Verificamos si proyección queda fuera de la pantalla actual
  bvec2 a = greaterThan(texcoord_past, vec2(1.0));
  bvec2 b = lessThan(texcoord_past, vec2(0.0));

  if (any(bvec2(any(a), any(b)))) {
    return current_color;
  } else {

    #if AA_TYPE == 2
      vec3 neighbourhood[9];

      neighbourhood[0] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y)).rgb;
      neighbourhood[1] = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y)).rgb;
      neighbourhood[2] = texture2D(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y)).rgb;
      neighbourhood[3] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0)).rgb;
      neighbourhood[4] = current_color;
      neighbourhood[5] = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0)).rgb;
      neighbourhood[6] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y)).rgb;
      neighbourhood[7] = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y)).rgb;
      neighbourhood[8] = texture2D(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y)).rgb;

      vec3 nmin = neighbourhood[0];
      vec3 nmax = nmin;
      for(int i = 1; i < 9; ++i) {
        nmin = min(nmin, neighbourhood[i]);
        nmax = max(nmax, neighbourhood[i]);
      }
    #else
      vec3 neighbourhood[5];

      neighbourhood[0] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y)).rgb;
      neighbourhood[1] = texture2D(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y)).rgb;
      neighbourhood[2] = current_color;
      neighbourhood[3] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y)).rgb;
      neighbourhood[4] = texture2D(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y)).rgb;

      vec3 nmin = neighbourhood[0];
      vec3 nmax = nmin;
      for(int i = 1; i < 5; ++i) {
        nmin = min(nmin, neighbourhood[i]);
        nmax = max(nmax, neighbourhood[i]);
      }
    #endif

    // Muestra del pasado
    vec3 previous = texture2D(colortex2, texcoord_past).rgb;
    vec3 past_sample = clamp(previous, nmin, nmax);

    // Reducción de ghosting por velocidad
    float blend = exp(-length(velocity * vec2(viewWidth, viewHeight))) * 0.3 + 0.6;

    // Reducción de ghosting por luma
    float luma_p = luma(previous);
    float clamped = distance(previous, past_sample) / luma_p;

    return mix(current_color, past_sample, clamp(blend - clamped, 0.0, 1.0));
  }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past, vec2 velocity) {
  // Verificamos si proyección queda fuera de la pantalla actual
  bvec2 a = greaterThan(texcoord_past, vec2(1.0));
  bvec2 b = lessThan(texcoord_past, vec2(0.0));

  if (any(bvec2(any(a), any(b)))) {
    return current_color;
  } else {
    #if AA_TYPE == 2
      vec4 neighbourhood[9];

      neighbourhood[0] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y));
      neighbourhood[1] = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y));
      neighbourhood[2] = texture2D(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y));
      neighbourhood[3] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0));
      neighbourhood[4] = current_color;
      neighbourhood[5] = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0));
      neighbourhood[6] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y));
      neighbourhood[7] = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y));
      neighbourhood[8] = texture2D(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y));

      vec4 nmin = neighbourhood[0];
      vec4 nmax = nmin;
      for(int i = 1; i < 9; ++i) {
        nmin = min(nmin, neighbourhood[i]);
        nmax = max(nmax, neighbourhood[i]);
      }
    #else
      vec4 neighbourhood[5];

      neighbourhood[0] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y));
      neighbourhood[1] = texture2D(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y));
      neighbourhood[2] = current_color;
      neighbourhood[3] = texture2D(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y));
      neighbourhood[4] = texture2D(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y));

      vec4 nmin = neighbourhood[0];
      vec4 nmax = nmin;
      for(int i = 1; i < 5; ++i) {
        nmin = min(nmin, neighbourhood[i]);
        nmax = max(nmax, neighbourhood[i]);
      }
    #endif

    // Muestra del pasado
    vec4 previous = texture2D(colortex2, texcoord_past);
    vec4 past_sample = clamp(previous, nmin, nmax);

    // Reducción de ghosting por velocidad
    float blend = exp(-length(velocity * vec2(viewWidth, viewHeight))) * 0.3 + 0.6;

    // Reducción de ghosting por luma
    float luma_p = luma(previous.rgb);
    float clamped = distance(previous, past_sample) / luma_p;

    return mix(current_color, past_sample, clamp(blend - clamped, 0.0, 1.0));
  }
}

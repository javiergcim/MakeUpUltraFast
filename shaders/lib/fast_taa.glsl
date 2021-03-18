/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 fast_taa(vec3 current_color, vec2 texcoord_past, vec2 velocity) {
  // Verificamos si proyección queda fuera de la pantalla actual
  bvec2 a = greaterThan(texcoord_past, vec2(1.0));
  bvec2 b = lessThan(texcoord_past, vec2(0.0));

  if (any(bvec2(any(a), any(b)))) {
    return current_color;
  } else {
    vec3 neighbourhood[5];

    neighbourhood[0] = texture(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y)).rgb;
    neighbourhood[1] = texture(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y)).rgb;
    neighbourhood[2] = current_color;
    neighbourhood[3] = texture(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y)).rgb;
    neighbourhood[4] = texture(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y)).rgb;

    vec3 nmin = neighbourhood[0];
    vec3 nmax = nmin;
    for(int i = 1; i < 5; ++i) {
      nmin = min(nmin, neighbourhood[i]);
      nmax = max(nmax, neighbourhood[i]);
    }

    // Muestra del pasado
    vec3 previous = texture(colortex3, texcoord_past).rgb;
    vec3 past_sample = clamp(previous, nmin, nmax);

    // Reducción de ghosting por velocidad
    float blend = exp(-length(velocity * vec2(viewWidth, viewHeight))) * 0.35 + 0.6;

    // Reducción de ghosting por luma
    float luma_p = luma(previous);
    float clamped = (distance(previous, past_sample) / luma_p);

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
    vec4 neighbourhood[5];

    neighbourhood[0] = texture(colortex1, texcoord + vec2(-pixel_size_x, -pixel_size_y));
    neighbourhood[1] = texture(colortex1, texcoord + vec2(pixel_size_x, -pixel_size_y));
    neighbourhood[2] = current_color;
    neighbourhood[3] = texture(colortex1, texcoord + vec2(-pixel_size_x, pixel_size_y));
    neighbourhood[4] = texture(colortex1, texcoord + vec2(pixel_size_x, pixel_size_y));

    vec4 nmin = neighbourhood[0];
    vec4 nmax = nmin;
    for(int i = 1; i < 5; ++i) {
      nmin = min(nmin, neighbourhood[i]);
      nmax = max(nmax, neighbourhood[i]);
    }

    // Muestra del pasado
    vec4 previous = texture(colortex3, texcoord_past);
    vec4 past_sample = clamp(previous, nmin, nmax);

    // Reducción de ghosting por velocidad
    float blend = exp(-length(velocity * vec2(viewWidth, viewHeight))) * 0.3 + 0.6;

    // Reducción de ghosting por luma
    float luma_p = luma(previous.rgb);
    float clamped = distance(previous, past_sample) / luma_p;

    return mix(current_color, past_sample, clamp(blend - clamped, 0.0, 1.0));
  }
}

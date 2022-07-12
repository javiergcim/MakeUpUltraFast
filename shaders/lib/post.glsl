vec3 sharpen(sampler2D image, vec3 color, vec2 coords) {
  vec3 sum = -texture2D(image, coords + vec2(-pixel_size_x, 0.0)).rgb;
  sum -= texture2D(image, coords + vec2(0.0, -pixel_size_y)).rgb;
  sum += 11.0 * color;
  sum -= texture2D(image, coords + vec2(0.0, pixel_size_y)).rgb;
  sum -= texture2D(image, coords + vec2(pixel_size_x, 0.0)).rgb;

  return sum * 0.14285714285714285;
}

vec3 edge_detect(sampler2D image, vec3 color, vec2 coords) {
  vec3 sum = -texture2D(image, coords + vec2(-pixel_size_x, -pixel_size_y)).rgb;
  sum -= texture2D(image, coords + vec2(pixel_size_x, -pixel_size_y)).rgb;
  sum += 4.0 * color;
  sum -= texture2D(image, coords + vec2(-pixel_size_x, pixel_size_y)).rgb;
  sum -= texture2D(image, coords + vec2(pixel_size_x, pixel_size_y)).rgb;

  return vec3(length(sum)) * 0.5773502691896258;
}

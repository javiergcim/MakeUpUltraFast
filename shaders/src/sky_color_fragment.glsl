vec4 fragpos = gbufferProjectionInverse *
(
  vec4(
  gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
  gl_FragCoord.z,
  1.0
  ) * 2.0 - 1.0
);
vec3 nfragpos = normalize(fragpos.xyz);
float n_u = clamp(dot(nfragpos, up_vec) + ((dither - .5) * 0.0625), 0.0, 1.0);

vec3 sky_base = mix(
  low_sky_color,
  hi_sky_color,
  sqrt(n_u)
);

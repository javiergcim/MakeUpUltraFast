vec3 motion_blur(vec3 color, float z_depth, vec2 blur_velocity) {
  if (z_depth > 0.56) {
    float mbwg = 0.0;
    vec2 double_pixel = 2.0 * vec2(pixel_size_x, pixel_size_y);
    vec3 mblur = vec3(0.0);

    blur_velocity =
      blur_velocity / (1.0 + length(blur_velocity)) *
      MOTION_BLUR_STRENGTH * 0.02;

    vec2 coord =
      texcoord - blur_velocity * (1.5 + dither_grad_noise(gl_FragCoord.xy));
    for(int i = 0; i < 5; i++, coord += blur_velocity){
      vec2 sample_coord = clamp(coord, double_pixel, 1.0 - double_pixel);
      float mask = float(texture2D(depthtex0, sample_coord).r > 0.56);
      mblur += texture2D(colortex1, sample_coord).rgb * mask;
      mbwg += mask;
    }
    mblur /= max(mbwg, 1.0);

    return mblur;
  } else {
    return color;
  }
}

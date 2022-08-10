/* MakeUp - motion_blur.glsl
Motion blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 motion_blur(vec3 color, float the_depth, vec2 blur_velocity, sampler2D image) {
  if (the_depth > 0.7) {  // Mano no
    vec2 double_pixels = 2.0 * vec2(pixel_size_x, pixel_size_y);
    vec3 m_blur = vec3(0.0);

    blur_velocity =
      (MOTION_BLUR_STRENGTH * blur_velocity) / ((1.0 + length(blur_velocity)) * (frameTime * 500.0)) ;

    #if AA_TYPE > 0
      vec2 coord =
        texcoord - blur_velocity * (1.5 + shifted_r_dither(gl_FragCoord.xy));
    #else
      vec2 coord =
        texcoord - blur_velocity * (1.5 + eclectic_r_dither(gl_FragCoord.xy));
    #endif

    float weight = 0.0;
    float mask;
    vec2 sample_coord;
    vec3 b_sample;
    for(int i = 0; i < MOTION_BLUR_SAMPLES; i++, coord += blur_velocity) {
      sample_coord = clamp(coord, double_pixels, 1.0 - double_pixels);
      // b_sample = texture2D(image, sample_coord, -3.0).rgb;
      b_sample = texture2DLod(image, sample_coord, 0.0).rgb;
      m_blur += b_sample;
      weight++;
    }
    m_blur /= max(weight, 1.0);

    return m_blur;
  } else {
    return color.rgb;
  }
}

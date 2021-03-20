/* MakeUp - motion_blur.glsl
Motion blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 motion_blur(vec4 color, vec2 blur_velocity, sampler2D image) {
  if (color.a > 0.7) {  // Mano no
    vec2 double_pixels = 2.0 * vec2(pixel_size_x, pixel_size_y);
    vec3 m_blur = vec3(0.0);

    blur_velocity =
      blur_velocity / (1.0 + length(blur_velocity)) * MOTION_BLUR_STRENGTH;

    vec2 coord =
      texcoord - blur_velocity * (1.5 + phi_noise(uvec2(gl_FragCoord.xy)));

    float weight = 0.0;
    float mask;
    vec2 sample_coord;
    vec4 b_sample;
    for(int i = 0; i < 3; i++, coord += blur_velocity) {
      sample_coord = clamp(coord, double_pixels, 1.0 - double_pixels);
      b_sample = texture(image, sample_coord);
      mask = float(b_sample.a > 0.7);  // Mano
      m_blur += b_sample.rgb * mask;
      weight += mask;
    }
    m_blur /= max(weight, 1.0);

    return m_blur;
  } else {
    return color.rgb;
  }
}

/* MakeUp Ultra Fast - bloom.glsl
Bloom functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 noised_bloom(sampler2D image, vec2 coords) {
  float blur_radius = 0.1;

  vec3 blur_sample = vec3(0.0);
  vec2 blur_radius_vec = vec2(blur_radius * inv_aspect_ratio, blur_radius);

  float sample_c_f =
      viewHeight * blur_radius * .25;

  int sample_c = int(sample_c_f);

  #if AA_TYPE == 1
    float dither = shifted_phi_noise(uvec2(gl_FragCoord.xy));
  #else
    float dither = phi_noise(uvec2(gl_FragCoord.xy));
    // float dither = texture_noise_64(gl_FragCoord.xy, colortex5);
  #endif

  float dither_base = dither;
  dither *= 6.283185307;

  float inv_steps = 1.0 / sample_c;
  float sample_angle_increment = 12.566370614359172 * inv_steps;
  float current_radius;
  vec2 offset;

  for(int i = 1; i <= sample_c; i++) {
    dither += sample_angle_increment;
    current_radius = (i + dither_base) * inv_steps;
    offset = vec2(cos(dither), sin(dither)) * blur_radius_vec * current_radius;

    blur_sample += texture(image, coords + offset).rgb;
    blur_sample += texture(image, coords - offset).rgb;
  }

  blur_sample /= (float(sample_c) * 2.0);

  return blur_sample;
}

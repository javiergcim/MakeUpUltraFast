/* MakeUp - bloom.glsl
Bloom functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 mipmap_bloom(sampler2D image, vec2 coords) {
  vec3 blur_sample = vec3(0.0);
  vec2 blur_radius_vec = vec2(0.125 * inv_aspect_ratio, 0.125);

  int sample_c = int(BLOOM_SAMPLES);

  #if AA_TYPE > 0
    float dither = shifted_phi_noise(uvec2(gl_FragCoord.xy));
  #else
    float dither = phi_noise(uvec2(gl_FragCoord.xy));
  #endif

  float dither_base = dither;
  dither *= 6.283185307;

  float inv_steps = 1.0 / BLOOM_SAMPLES;
  float sample_angle_increment = 12.566370614359172 * inv_steps;
  float current_radius;
  vec2 offset;

  for(int i = 0; i < sample_c; i++) {
    dither += sample_angle_increment;
    current_radius = (i + dither_base) * inv_steps;
    offset = vec2(cos(dither), sin(dither)) * blur_radius_vec * current_radius;

    blur_sample += texture(image, coords + offset, -2.5).rgb;
    blur_sample += texture(image, coords - offset, -2.5).rgb;
  }

  blur_sample /= (BLOOM_SAMPLES * 2.0);

  return blur_sample;
}

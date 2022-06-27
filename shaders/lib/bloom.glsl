/* MakeUp - bloom.glsl
Bloom functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 mipmap_bloom(sampler2D image, vec2 coords, float dither, float inv_aspect_ratio) {
  vec3 blur_sample = vec3(0.0);
  vec2 blur_radius_vec = vec2(0.1 * inv_aspect_ratio, 0.1);

  int sample_c = int(BLOOM_SAMPLES);

  float dither_base = dither;
  dither *= 3.141592653589793;

  float inv_steps = 1.0 / BLOOM_SAMPLES;
  float sample_angle_increment = 1636.7697725202822 * inv_steps;
  float current_radius;
  vec2 offset;

  for(int i = 0; i < sample_c; i++) {
    dither += sample_angle_increment;
    current_radius = (i + dither_base) * inv_steps;
    offset = vec2(cos(dither), sin(dither)) * blur_radius_vec * current_radius;

    blur_sample += texture2D(image, coords + offset, -1.0).rgb;
    blur_sample += texture2D(image, coords - offset, -1.0).rgb;
  }

  blur_sample /= (BLOOM_SAMPLES * 2.0);

  return blur_sample;
}

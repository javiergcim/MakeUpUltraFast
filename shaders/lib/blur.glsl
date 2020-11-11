/* MakeUp Ultra Fast - blur.glsl
Blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 noised_blur(vec4 color_depth, sampler2D image, vec2 coords, float force) {
  vec3 block_color = color_depth.rgb;
  float the_depth = color_depth.a;
  float blur_radius = 0.0;

  // if (the_depth > 0.56) {  // Manos no
  if (the_depth > 0.7) {  // Manos no
    blur_radius =
      max(abs(the_depth - centerDepthSmooth) - 0.0001, 0.0);
    blur_radius = blur_radius / sqrt(0.1 + blur_radius * blur_radius) * force;
    blur_radius = min(blur_radius, 0.05);
  }

  if (blur_radius > min(pixel_size_x, pixel_size_y)) {
    vec3 blur_sample = vec3(0.0);
    vec2 blur_radius_vec = vec2(blur_radius * inv_aspect_ratio, blur_radius);

    #if AA_TYPE == 1 || AA_TYPE == 2
      float sample_c_f =
        max(viewHeight * blur_radius * .333333 * DOF_SAMPLES_FACTOR, 2.0);
    #else
      float sample_c_f =
        max(viewHeight * blur_radius * .333333 * DOF_SAMPLES_FACTOR, 2.0);
    #endif
    int sample_c = int(sample_c_f);
    vec2 offset;

    float dither = hash12(gl_FragCoord.xy);
    float distance_step = 1.0 / sample_c_f;
    float current_distance = 0.0;

    for(int i = 0; i < sample_c; i++) {
      #if AA_TYPE == 1 || AA_TYPE == 2
        dither = timed_hash11(dither) * 3.141592;
      #else
        dither = hash11(dither) * 3.141592;
      #endif

      current_distance += distance_step;

      offset =
        vec2(cos(dither), sin(dither)) *
        blur_radius_vec *
        current_distance;

      blur_sample += texture2D(image, coords + offset).rgb;
      blur_sample += texture2D(image, coords - offset).rgb;
    }

    blur_sample /= (float(sample_c) * 2.0);
    block_color = blur_sample;
  }

  return block_color;
}

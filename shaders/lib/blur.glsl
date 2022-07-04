/* MakeUp - blur.glsl
Blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 noised_blur(vec4 color_depth, sampler2D image, vec2 coords, float force, float dither) {
  vec3 block_color = color_depth.rgb;
  float the_depth = color_depth.a;
  float blur_radius = 0.0;

  if (the_depth > 0.56) {  // Manos no
    blur_radius =
      max(abs(the_depth - centerDepthSmooth) - 0.000075, 0.0) * fov_y_inv;
    blur_radius = blur_radius * inversesqrt(0.1 + blur_radius * blur_radius) * force;
    blur_radius = min(blur_radius, 0.1);
  }

  if (blur_radius > min(pixel_size_x, pixel_size_y)) {
    vec3 blur_sample = vec3(0.0);
    vec2 blur_radius_vec = vec2(blur_radius * inv_aspect_ratio, blur_radius);

    float dither_base = dither;
    dither *= 6.283185307179586;

    float current_radius = (0.25 + dither_base);
    vec2 offset = vec2(cos(dither), sin(dither)) * blur_radius_vec * current_radius;

    blur_sample += texture2D(image, coords + offset, -2.0).rgb;
    blur_sample += texture2D(image, coords - offset, -2.0).rgb;

    block_color = blur_sample * 0.5;
  }

  return block_color;
}

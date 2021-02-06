/* MakeUp Ultra Fast - ao.glsl
Based on Capt Tatsu's ambient occlusion functions.

*/

float dbao() {
  float ao = 0.0;

  #if AA_TYPE == 1
    float dither = shifted_phi_noise(uvec2(gl_FragCoord.xy));
  #else
    float dither = texture_noise_64(gl_FragCoord.xy, colortex5);
  #endif

  float dither_base = dither;
  dither *= 6.283185307;

  float inv_steps = 1.0 / AOSTEPS;
  float sample_angle_increment = 3.1415926535 * inv_steps;
  float current_radius;
  vec2 offset;

  float d = texture(depthtex0, texcoord.xy).r;
  float hand = float(d < 0.7);
  d = ld(d);

  float sd = 0.0;
  float angle = 0.0;
  float dist = 0.0;
  float far_double = 2.0 * far;
  vec2 scale = vec2(inv_aspect_ratio, 1.0) * (fov_y_inv / (d * far));

  for (int i = 1; i <= AOSTEPS; i++) {
    dither += sample_angle_increment;
    current_radius = (i + dither_base) * inv_steps;
    offset = vec2(cos(dither), sin(dither)) * scale * current_radius;

    sd = ld(texture(depthtex0, texcoord.xy + offset).r);
    float sample = (d - sd) * far_double;
    if (hand > 0.7) sample *= 1024.0;
    angle = clamp(0.5 - sample, 0.0, 1.0);
    dist = clamp(0.25 * sample - 1.0, 0.0, 1.0);

    sd = ld(texture(depthtex0, texcoord.xy - offset).r);
    sample = (d - sd) * far_double;
    if (hand > 0.7) sample *= 1024.0;
    angle += clamp(0.5 - sample, 0.0, 1.0);
    dist += clamp(0.25 * sample - 1.0, 0.0, 1.0);

    ao += clamp(angle + dist, 0.0, 1.0);
  }
  ao /= AOSTEPS;

  return (ao * AO_STRENGHT) + (1.0 - AO_STRENGHT);
}

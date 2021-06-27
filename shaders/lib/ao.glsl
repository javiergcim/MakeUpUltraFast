/* MakeUp - ao.glsl
Based on Capt Tatsu's ambient occlusion functions.

*/

float dbao(float dither) {
  float ao = 0.0;

  float dither_base = dither;
  dither *= 6.283185307;

  float inv_steps = 1.0 / AOSTEPS;
  float sample_angle_increment = 6.283185307 * inv_steps;
  float current_radius;
  vec2 offset;

  float d = texture2D(depthtex0, texcoord.xy).r;
  float hand_check = d < 0.56 ? 1024.0 : 1.0;
  d = ld(d);

  float sd = 0.0;
  float angle = 0.0;
  float dist = 0.0;
  float far_double = 2.0 * far;
  vec2 scale = vec2(inv_aspect_ratio, 1.0) * (fov_y_inv / (d * far));
  float sample_d;

  for (int i = 1; i <= AOSTEPS; i++) {
    dither += sample_angle_increment;
    current_radius = (i + dither_base) * inv_steps;
    offset = vec2(cos(dither), sin(dither)) * scale * current_radius;

    sd = ld(texture2D(depthtex0, texcoord.xy + offset).r);
    sample_d = (d - sd) * far_double * hand_check;
    angle = clamp(0.5 - sample_d, 0.0, 1.0);
    dist = clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

    sd = ld(texture2D(depthtex0, texcoord.xy - offset).r);
    sample_d = (d - sd) * far_double * hand_check;
    angle += clamp(0.5 - sample_d, 0.0, 1.0);
    dist += clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

    ao += clamp(angle + dist, 0.0, 1.0);
  }
  ao /= AOSTEPS;

  return (ao * AO_STRENGHT) + (1.0 - AO_STRENGHT);
}

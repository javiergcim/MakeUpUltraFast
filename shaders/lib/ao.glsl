/* MakeUp Ultra Fast - dither.glsl
Capt Tatsu's ambient occlusion functions.

*/

vec2 offset_dist(float x, int s){
  float n = fract(x * 1.414) * 3.1415;
  return vec2(cos(n), sin(n)) * x / s;
}

float dbao() {
  float ao = 0.0;

  #if AA_TYPE == 2
    float dither = timed_hash12();
  #else
    float dither = texture_noise_32(gl_FragCoord.xy, colortex6);
  #endif

  // float base_angle = texture_noise_32(gl_FragCoord.xy, colortex6);
  // float rot_step = 10.681415022205297 / AOSTEPS;
  // float sample_angle = base_angle * 6.2831853;

  float d = texture2D(depthtex0, texcoord.xy).r;
  float hand = float(d < 0.56);
  d = ld(d);

  float sd = 0.0;
  float angle = 0.0;
  float dist = 0.0;
  float far_double = 2.0 * far;
  // vec2 scale = vec2(1.0 / aspectRatio, 1.0) * gbufferProjection[1][1] / (2.74747742 * max(far * d, 6.0));
  vec2 scale = vec2(1.0, aspectRatio) * (0.4 / (d * far));

  for (int i = 1; i <= AOSTEPS; i++) {
    vec2 offset = offset_dist(i + dither, AOSTEPS) * scale;
    // sample_angle += (i * rot_step);
    // vec2 offset = vec2(cos(sample_angle), sin(sample_angle)) * ((i + base_angle) / AOSTEPS) * scale;

    sd = ld(texture2D(depthtex0, texcoord.xy + offset).r);
    float sample = (d - sd) * far_double;
    if (hand > 0.5) sample *= 1024.0;
    angle = clamp(0.5 - sample, 0.0, 1.0);
    dist = clamp(0.25 * sample - 1.0, 0.0, 1.0);

    sd = ld(texture2D(depthtex0, texcoord.xy - offset).r);
    sample = (d - sd) * far_double;
    if (hand > 0.5) sample *= 1024.0;
    angle += clamp(0.5 - sample, 0.0, 1.0);
    dist += clamp(0.25 * sample - 1.0, 0.0, 1.0);

    ao += clamp(angle + dist, 0.0, 1.0);
  }
  ao /= AOSTEPS;

  return (ao * AO_STRENGHT) + (1.0 - AO_STRENGHT);
}

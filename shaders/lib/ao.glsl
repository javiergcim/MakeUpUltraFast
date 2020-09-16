/* MakeUp Ultra Fast - dither.glsl
Capt Tatsu's ambient occlusion functions.

*/

vec2 offsetDist(float x, int s){
  float n = fract(x * 1.414) * 3.1415;
  return vec2(cos(n), sin(n)) * x / s;
}

float dbao(sampler2D depth, float dither){
  float ao = 0.0;

  int samples = AOSTEPS;

  float d = texture2D(depth, texcoord.xy).r;
  float hand = float(d < 0.56);
  d = ld(d);

  float sd = 0.0;
  float angle = 0.0;
  float dist = 0.0;
  // vec2 scale = SIZE * vec2(1.0 / aspectRatio, 1.0) * gbufferProjection[1][1] / (2.74747742 * max(far * d, 6.0));
  vec2 scale = vec2(1.0 / aspectRatio, 1.0) * gbufferProjection[1][1] / (2.74747742 * max(far * d, 6.0));

  for (int i = 1; i <= samples; i++) {
    vec2 offset = offsetDist(i + dither, samples) * scale;

    sd = ld(texture2D(depth, texcoord.xy + offset).r);
    float tmp = far * 2.0;
    float sample = (d - sd) * tmp;
    if (hand > 0.5) sample *= 1024.0;
    angle = clamp(0.5 - sample, 0.0, 1.0);
    dist = clamp(0.25 * sample - 1.0, 0.0, 1.0);

    sd = ld(texture2D(depth, texcoord.xy - offset).r);
    sample = (d - sd) * tmp;
    if (hand > 0.5) sample *= 1024.0;
    angle += clamp(0.5 - sample, 0.0, 1.0);
    dist += clamp(0.25 * sample - 1.0, 0.0, 1.0);

    ao += clamp(angle + dist, 0.0, 1.0);
  }
  ao /= samples;

  return (ao * AO_STRENGHT) + (1.0 - AO_STRENGHT);
}

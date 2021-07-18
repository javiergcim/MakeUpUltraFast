/* MakeUp - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 lottes_tonemap(vec3 x, float hdrMax) {
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    // float a = 1.5;
    // float d = 0.977;
    // const float hdrMax = 8.0;
    // float midIn = 0.2;
    // float midOut = 0.27;

    float pow_a = pow(hdrMax, 1.5);
    float pow_b = pow(hdrMax, 1.4655);
    float producto_a = (pow_b - 0.0945495483551584) * 0.27;

    float b =
        (-0.0894427190999916 + pow_a * 0.27) /
        producto_a;
    float c =
        (pow_b * 0.0894427190999916 - pow_a * 0.02552837805589277) /
        producto_a;

    return pow(x, vec3(1.5)) / (pow(x, vec3(1.4655)) * vec3(b) + vec3(c));
}

// vec3 lottes_tonemap(vec3 x, float hdrMax) {
//     // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
//     float a = 1.5;
//     float d = 0.977;
//     // const float hdrMax = 8.0;
//     float midIn = 0.2;
//     float midOut = 0.27;
//
//     // Can be precomputed
//     float b =
//         (-pow(midIn, a) + pow(hdrMax, a) * midOut) /
//         ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
//     float c =
//         (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) /
//         ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
//
//     return pow(x, vec3(a)) / (pow(x, vec3(a * d)) * vec3(b) + vec3(c));
// }

vec3 uchimura(vec3 x, float P, float a, float m, float l, float c, float b) {
  float l0 = ((P - m) * l) / a;
  float L0 = m - m / a;
  float L1 = m + (1.0 - m) / a;
  float S0 = m + l0;
  float S1 = m + a * l0;
  float C2 = (a * P) / (P - S1);
  float CP = -C2 / P;

  vec3 w0 = vec3(1.0 - smoothstep(0.0, m, x));
  vec3 w2 = vec3(step(m + l0, x));
  vec3 w1 = vec3(1.0 - w0 - w2);

  vec3 T = vec3(m * pow(x / m, vec3(c)) + b);
  vec3 S = vec3(P - (P - S1) * exp(CP * (x - S0)));
  vec3 L = vec3(m + a * (x - m));

  return T * w0 + L * w1 + S * w2;
}

// vec3 lottes_tonemap(vec3 x, float z) {
//   const float P = 1.0;  // max display brightness
//   const float a = 1.1;  // contrast
//   const float m = 0.1; // linear section start
//   const float l = 0.5;  // linear section length
//   const float c = 1.33; // black
//   const float b = 0.0;  // pedestal
//
//   return uchimura(x, P, a, m, l, c, b);
// }

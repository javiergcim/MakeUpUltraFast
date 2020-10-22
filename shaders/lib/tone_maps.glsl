/* MakeUp Ultra Fast - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 original_tonemap(vec3 x) {
  return x / pow(vec3_fourth_pow(x) + 1.0, vec3(.25));
}

// vec3 custom_lottes_tonemap(vec3 x, float expo) {
//     // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
// 		float pow_a = pow(expo, 1.386);
// 		float pow_b = pow(expo, 1.4);
//
//     float b =
//         (-0.37892914162759955 + pow_b * 0.55) /
//         ((pow_a - 0.3826241924556669) * 0.55);
//     float c =
//         (pow_a * 0.37892914162759955 - pow_b * 0.21044330585061682) /
//         ((pow_a - 0.3826241924556669) * 0.55);
//
//     return pow(x, vec3(1.4)) / (pow(x, vec3(1.386)) * b + c);
// }

vec3 lottes_tonemap(vec3 x, float hdrMax) {
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    float a = 1.3;
    float d = 0.997;
    // const float hdrMax = 8.0;
    float midIn = 0.2;
    float midOut = 0.24;

    // Can be precomputed
    float b =
        (-pow(midIn, a) + pow(hdrMax, a) * midOut) /
        ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
    float c =
        (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) /
        ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);

    return pow(x, vec3(a)) / (pow(x, vec3(a * d)) * b + c);
}

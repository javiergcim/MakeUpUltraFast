/* MakeUp - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 lottes_tonemap(vec3 x, float expo) {
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    // float a = 1.35;
    // float d = 0.977;
    // float midIn = 0.2;
    // float midOut = 0.25;

    float pow_a = pow(expo, 1.34595);
    float pow_b = pow(expo, 1.35);
    float product_a = (pow_a - 0.11460968599571732) * 0.25;

    float b =
        (-0.11386506388503059 + pow_b * 0.25) /
        product_a;
    float c =
        (pow_a * 0.11386506388503059 - pow_b * 0.11460968599571732 * 0.25) /
        product_a;

    return pow(x, vec3(1.35)) / (pow(x, vec3(1.34595)) * vec3(b) + vec3(c));
}

// vec3 lottes_tonemap(vec3 x, float hdrMax) {
//     // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
//     float a = 1.35;
//     float d = 0.977;
//     // const float hdrMax = 8.0;
//     float midIn = 0.2;
//     float midOut = 0.25;
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

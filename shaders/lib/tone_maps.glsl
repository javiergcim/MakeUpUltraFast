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

    // Can be precomputed
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

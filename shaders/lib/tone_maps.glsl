/* MakeUp - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 custom_sigmoid(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(3.0)) + 1.0, vec3(0.3333333333333));

    return pow(color, vec3(1.15));
}

// vec3 custom_sigmoid(vec3 color) {
//     // ((1.4 ∙ x) / ((1.4 ∙ x)^2.5 + 1)^0.4)^1.1
//     color = 1.4 * color;
//     color = color / pow(pow(color, vec3(2.5)) + 1.0, vec3(0.4));

//     return pow(color, vec3(1.1));
// }

vec3 custom_sigmoid_alt(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(3.05)) + 1.0, vec3(0.3278688524590164));

    return pow(color, vec3(1.15));
}
/* MakeUp - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 custom_sigmoid(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(2.6)) + 1.0, vec3(0.3846153846153846));
    // color = color / pow(pow(color, vec3(2.25)) + 1.0, vec3(0.4444444444444444));

    return pow(color, vec3(1.1));
}

vec3 custom_sigmoid_alt(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(3.0)) + 1.0, vec3(0.3333333333333333));

    return pow(color, vec3(1.1));
}

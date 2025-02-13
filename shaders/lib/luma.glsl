/* MakeUp - luma.glsl
Luma related functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float luma(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

float color_average(vec3 color) {
    return (color.r + color.g + color.b) * 0.3333333333;
}

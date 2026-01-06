/* MakeUp - basic_utils.glsl
Misc utilities.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float squarePow(float x) {
    return x * x;
}

float cubePow(float x) {
    return x * x * x;
}

float fourthPow(float x) {
    float temp_2 = x * x;
    return temp_2 * temp_2;
}

float fifthPow(float x) {
    float temp_2 = x * x;
    return temp_2 * temp_2 * x;
}

float sixthPow(float x) {
    float temp_2 = x * x;
    return temp_2 * temp_2 * temp_2;
}

vec3 SquarePowVec3(vec3 x) {
    return x * x;
}

vec3 cubePowVec3(vec3 x) {
    return x * x * x;
}

vec3 fourthPowVec3(vec3 x) {
    vec3 temp_2 = x * x;
    return temp_2 * temp_2;
}

vec3 fifthPowVec3(vec3 x) {
    vec3 temp_2 = x * x;
    return temp_2 * temp_2 * x;
}

vec3 sixthPowVec3(vec3 x) {
    vec3 temp_2 = x * x;
    return temp_2 * temp_2 * temp_2;
}

vec4 squarePowVec4(vec4 x) {
    return x * x;
}

vec4 cubePowVec4(vec4 x) {
    return x * x * x;
}

vec4 fourthPowVec4(vec4 x) {
    return x * x * x * x;
}

vec4 fifthPowVec4(vec4 x) {
    vec4 temp_2 = x * x;
    return temp_2 * temp_2 * x;
}

vec4 sixthPowVec4(vec4 x) {
    vec4 temp_2 = x * x;
    return temp_2 * temp_2 * temp_2;
}

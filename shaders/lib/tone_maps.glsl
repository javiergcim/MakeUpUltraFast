/* MakeUp - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 custom_ACES(vec3 x) {
    // Narkowicz 2015, "ACES Filmic Tone Mapping Curve"
    float a = 2.845;
    float b = 0.3;
    float c = 2.76;
    float d = 0.7;
    float e = 0.4;

    return (x * (a * x + vec3(b))) / (x * (c * x + vec3(d)) + vec3(e));
}

vec3 custom_ACES_alt(vec3 x) {
    // Narkowicz 2015, "ACES Filmic Tone Mapping Curve"
    float a = 2.71;
    float b = 1.0;
    float c = 2.43;
    float d = 1.0;
    float e = 0.95;

    return (x * (a * x + vec3(b))) / (x * (c * x + vec3(d)) + vec3(e));
}

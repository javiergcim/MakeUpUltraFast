/* MakeUp - color_blindness.glsl
The correction algorithm is taken from http://www.daltonize.org/search/label/Daltonize

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 color_blindness(vec3 color) {	
    float L = (17.8824 * color.r) + (43.5161 * color.g) + (4.11935 * color.b);
    float M = (3.45565 * color.r) + (27.1554 * color.g) + (3.86714 * color.b);
    float S = (0.0299566 * color.r) + (0.184309 * color.g) + (1.46709 * color.b);

    float l, m, s;
    #if COLOR_BLIND_MODE == 0  // Protanopia
        l = 0.0 * L + 2.02344 * M + -2.52581 * S;
        m = 0.0 * L + 1.0 * M + 0.0 * S;
        s = 0.0 * L + 0.0 * M + 1.0 * S;
    #elif COLOR_BLIND_MODE == 1  // Deutranopia
        l = 1.0 * L + 0.0 * M + 0.0 * S;
        m = 0.494207 * L + 0.0 * M + 1.24827 * S;
        s = 0.0 * L + 0.0 * M + 1.0 * S;
    #elif COLOR_BLIND_MODE == 2  // Tritanopia
        l = 1.0 * L + 0.0 * M + 0.0 * S;
        m = 0.0 * L + 1.0 * M + 0.0 * S;
        s = -0.395913 * L + 0.801109 * M + 0.0 * S;
    #endif

    vec3 error;
    error.r = (0.0809444479 * l) + (-0.130504409 * m) + (0.116721066 * s);
    error.g = (-0.0102485335 * l) + (0.0540193266 * m) + (-0.113614708 * s);
    error.b = (-0.000365296938 * l) + (-0.00412161469 * m) + (0.693511405 * s);

    vec3 diff = color - error;
    vec3 correction;
    correction.r = 0.0;
    correction.g = (diff.r * 0.7) + (diff.g * 1.0);
    correction.b = (diff.r * 0.7) + (diff.b * 1.0);
    correction = color + correction;

    return correction;
}
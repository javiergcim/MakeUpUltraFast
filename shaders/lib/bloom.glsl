/* MakeUp - bloom.glsl
Bloom functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 mipmap_bloom(sampler2D image, vec2 coords, float dither) {
    vec3 blurSample = vec3(0.0);
    vec2 blurRadiusVec = vec2(0.1 * aspectRatioInverse, 0.1);

    int samplesQuantity = int(BLOOM_SAMPLES);

    vec2 blurRadiusFactor = blurRadiusVec * (1.0 / BLOOM_SAMPLES);
    float n;
    vec2 offset;
    vec2 offset2;
    float ditherShifted;

    for(int i = 0; i < samplesQuantity; i++) {
        ditherShifted = i + dither;
        n = fract(ditherShifted * 1.6180339887) * 6.283185307179586;
        offset = vec2(cos(n), sin(n)) * ditherShifted * blurRadiusFactor;
        offset2 = vec2(-offset.y * 1.25, offset.x * 1.25);

        blurSample += texture2DLod(image, coords + offset, softLod).rgb;
        blurSample += texture2DLod(image, coords - offset, softLod).rgb;
        blurSample += texture2DLod(image, coords + offset2, softLod).rgb;
        blurSample += texture2DLod(image, coords - offset2, softLod).rgb;
    }

    blurSample /= (BLOOM_SAMPLES * 4.0);

    return blurSample;
}

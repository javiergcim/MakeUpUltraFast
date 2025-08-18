/* MakeUp - bloom.glsl
Bloom functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 mipmap_bloom(sampler2D image, vec2 coords, float dither) {
    vec3 blur_sample = vec3(0.0);
    vec2 blur_radius_vec = vec2(0.1 * inv_aspect_ratio, 0.1);

    int sample_c = int(BLOOM_SAMPLES);

    vec2 blur_radios_factor = blur_radius_vec * (1.0 / BLOOM_SAMPLES);
    float n;
    vec2 offset;
    vec2 offset_2;
    float dither_x;

    for(int i = 0; i < sample_c; i++) {
        dither_x = i + dither;
        n = fract(dither_x * 1.6180339887) * 6.283185307179586;
        offset = vec2(cos(n), sin(n)) * dither_x * blur_radios_factor;
        offset_2 = vec2(-offset.y * 1.25, offset.x * 1.25);

        blur_sample += texture2D(image, coords + offset, -1.0).rgb;
        blur_sample += texture2D(image, coords - offset, -1.0).rgb;
        blur_sample += texture2D(image, coords + offset_2, -1.0).rgb;
        blur_sample += texture2D(image, coords - offset_2, -1.0).rgb;
    }

    blur_sample /= (BLOOM_SAMPLES * 4.0);

    return blur_sample;
}

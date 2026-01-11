/* MakeUp - motion_blur.glsl
Motion blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 motion_blur(vec3 color, float depthAlone, vec2 blur_velocity, float dither, sampler2D image) {
    if (depthAlone > 0.7) {  // No hand
        vec2 double_pixels = 2.0 * vec2(pixelSizeX, pixelSizeY);
        vec3 m_blur = vec3(0.0);

        blur_velocity =
            (MOTION_BLUR_STRENGTH * blur_velocity) / ((1.0 + length(blur_velocity)) * (frameTime * 500.0)) ;

        vec2 coord =
            texcoord - blur_velocity * (1.5 + dither);

        float weight = 0.0;
        float mask;
        vec2 sample_coord;
        vec3 b_sample;
        for(int i = 0; i < MOTION_BLUR_SAMPLES; i++, coord += blur_velocity) {
            sample_coord = clamp(coord, double_pixels, 1.0 - double_pixels);
            b_sample = texture2DLod(image, sample_coord, 0.0).rgb;
            m_blur += b_sample;
            weight++;
        }
        m_blur /= max(weight, 1.0);

        return m_blur;
    } else {
        return color.rgb;
    }
}

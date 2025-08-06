/* MakeUp - ao.glsl
Based on old Capt Tatsu's ambient occlusion functions.

*/

float dbao(float dither) {
    float ao = 0.0;

    float inv_steps = 1.0 / AOSTEPS;
    vec2 offset;
    float n;
    float dither_x;

    float d = texture2DLod(depthtex0, texcoord.xy, 0.0).r;
    float hand_check = d < 0.56 ? 1024.0 : 1.0;
    d = ld(d);

    float sd = 0.0;
    float angle = 0.0;
    float dist = 0.0;
    float far_and_check = hand_check * 2.0 * far;
    vec2 scale = vec2(inv_aspect_ratio, 1.0) * (fov_y_inv / (d * far));
    vec2 scale_factor = scale * inv_steps;
    float sample_d;

    for (int i = 0; i < AOSTEPS; i++) {
        dither_x = (i + dither);
        n = fract(dither_x * 1.6180339887) * 3.141592653589793;
        offset = vec2(cos(n), sin(n)) * dither_x * scale_factor;

        sd = ld(texture2DLod(depthtex0, texcoord.xy + offset, 0.0).r);
        sample_d = (d - sd) * far_and_check;
        angle = clamp(0.5 - sample_d, 0.0, 1.0);
        dist = clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

        sd = ld(texture2DLod(depthtex0, texcoord.xy - offset, 0.0).r);
        sample_d = (d - sd) * far_and_check;
        angle += clamp(0.5 - sample_d, 0.0, 1.0);
        dist += clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

        ao += clamp(angle + dist, 0.0, 1.0);
    }
    ao /= AOSTEPS;

    return sqrt((ao * AO_STRENGTH) + (1.0 - AO_STRENGTH));
}

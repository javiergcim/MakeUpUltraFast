/* MakeUp - ambientOcclusion.glsl
Based on old Capt Tatsu's ambient occlusion functions.

*/

float dbao(float dither) {
    float ambientOcclusion = 0.0;

    float stepsInverse = 1.0 / AOSTEPS;
    vec2 offset;
    float n;
    float ditherSample;

    float linearDepth = texture2DLod(depthtex0, texcoord.xy, 0.0).r;
    float handCheck = linearDepth < 0.56 ? 1024.0 : 1.0;
    linearDepth = ld(linearDepth);

    float sampleLinearDepth = 0.0;
    float angle = 0.0;
    float dist = 0.0;
    float farAndCheck = handCheck * 2.0 * far;
    vec2 scale = vec2(aspectRatioInverse, 1.0) * (fovYInverse / (linearDepth * far));
    vec2 scaleFactor = scale * stepsInverse;
    float checkDepth;

    for (int i = 0; i < AOSTEPS; i++) {
        ditherSample = (i + dither);
        n = fract(ditherSample * 1.6180339887) * 3.141592653589793;
        offset = vec2(cos(n), sin(n)) * ditherSample * scaleFactor;

        sampleLinearDepth = ld(texture2DLod(depthtex0, texcoord.xy + offset, 0.0).r);
        checkDepth = (linearDepth - sampleLinearDepth) * farAndCheck;
        angle = clamp(0.5 - checkDepth, 0.0, 1.0);
        dist = clamp(0.25 * checkDepth - 1.0, 0.0, 1.0);

        sampleLinearDepth = ld(texture2DLod(depthtex0, texcoord.xy - offset, 0.0).r);
        checkDepth = (linearDepth - sampleLinearDepth) * farAndCheck;
        angle += clamp(0.5 - checkDepth, 0.0, 1.0);
        dist += clamp(0.25 * checkDepth - 1.0, 0.0, 1.0);

        ambientOcclusion += clamp(angle + dist, 0.0, 1.0);
    }
    ambientOcclusion /= AOSTEPS;

    return sqrt((ambientOcclusion * AO_STRENGTH) + (1.0 - AO_STRENGTH));
}

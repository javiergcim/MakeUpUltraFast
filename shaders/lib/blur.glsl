/* MakeUp - blur.glsl
Blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 noisedBlur(vec4 colorAndDepth, sampler2D image, vec2 coords, float force, float dither) {
    vec3 blockColor = colorAndDepth.rgb;
    float depthAlone = colorAndDepth.a;
    float blurRadius = 0.0;

    if (depthAlone > 0.56) {  // Manos no
        blurRadius =
            max(abs(depthAlone - centerDepthSmooth) - 0.000075, 0.0) * fovYInverse;
        blurRadius = blurRadius * inversesqrt(0.1 + blurRadius * blurRadius) * force;
        blurRadius = min(blurRadius, 0.1);
    }

    if (blurRadius > min(pixelSizeX, pixelSizeY)) {
        vec3 blurSample = vec3(0.0);
        vec2 blurRadiusVec = vec2(blurRadius * aspectRatioInverse, blurRadius);

        float dither_base = dither;
        dither *= 6.283185307179586;

        float current_radius = (0.25 + dither_base);
        vec2 offset = vec2(cos(dither), sin(dither)) * blurRadiusVec * current_radius;

        blurSample += texture2D(image, coords + offset, -2.0).rgb;
        blurSample += texture2D(image, coords - offset, -2.0).rgb;

        blockColor = blurSample * 0.5;
    }

    return blockColor;
}

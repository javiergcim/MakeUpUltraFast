/* MakeUp - dither.glsl
Dither and hash functions

There are a multitude of dithers in MakeUp, with different variants.

There are fixed ones (that do not change over time) as well as those that change
when temporal sampling is active. Of the latter, there are two versions:
one that uses ditherShift (Minecraft 1.13+) and another that uses frameMod
to rotate the dither values.

There are several variants because each one performs better or worse
depending on the situation in which it is used.

The philosophy of their use is as follows:
1) use the fastest one possible that still produces acceptable results.
2) If multiple effects use a dithering and they are in the same step
of the Optifine/Iris pipeline, then calculate the dithering only once
and use it in all the effects that need it to avoid redundant calculations.

The variants that change over time have the prefix "shifted".

The variants with the prefix 'eclectic' are perturbed versions of their simpler counterparts.
They offer good results because they avoid the appearance of repetitive patterns,
but they require the calculation of a hash to create this perturbation.

There is a function based on a texture, which assumes a size for the texture of 64x64 pixels,
but there is no such texture currently.

*/


uniform int frameMod;

#if MC_VERSION >= 11300
    uniform float ditherShift;
#else
    float ditherShift = frameMod * 0.1875;
#endif

float hash12(vec2 point)
{
    point = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(point * point, vec2(3571.0)));
    return fract(state * state * 7142.0);
}

float hash13(vec3 point)
{
    point = fract(point * .1031);
    point += dot(point, point.zyx + 31.32);
    return fract((point.x + point.y) * point.z);
}

vec2 hash22(vec2 point)
{
	vec3 p3 = fract(vec3(point.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

float rDither(vec2 point) {
    return fract(dot(point, vec2(0.75487766624669276, 0.569840290998)));
}

float eclecticRDither(vec2 point) {
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.075;

    return fract(dot(point, vec2(0.75487766624669276, 0.569840290998)) + p4);
}

float dither13(vec2 point) {
    return fract(dot(point, vec2(0.3076923076923077, 0.5384615384615384)));
}

float eclecticDither13(vec2 point) {
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.075;

    return fract(dot(point, vec2(0.3076923076923077, 0.5384615384615384)) + p4);
}

float dither17(vec2 point) {
  return fract(dot(point, vec2(0.11764705882352941, 0.4117647058823529)));
}

float eclecticDither17(vec2 point) {
  vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
  float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
  float p4 = fract(state * state * 7142.0) * 0.15;

  return fract(p4 + dot(point, vec2(0.11764705882352941, 0.4117647058823529)));
}

float ditherGradNoise(vec2 point) {
    return fract(52.9829189 * fract(dot(vec2(0.06711056, 0.00583715), point)));
}

float eclecticDitherGradNoise(vec2 point) {
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.075;

    return fract(52.9829189 * fract(dot(vec2(0.06711056, 0.00583715), point)) + p4);
}

float textureNoise64(vec2 point, sampler2D noise) {
    return texture2DLod(noise, point * 0.015625, 0).r;
}

float semiblue(vec2 point) {
    vec2 tile = floor(point * 0.25);
    float flip = mod(tile.x + tile.y, 2.0);
    point = mix(point, point.yx, flip);

    return fract(dot(vec2(0.75487766624669276, 0.569840290998), point) + hash12(tile));
}

float ditherMakeup(vec2 point) {
    vec2 tile = floor(point * 0.125);
    float flip = mod(tile.x + tile.y, 2.0);
    vec2 rPoint = mix(point, point.yx, flip);

    return fract(
        dot(vec2(0.24512233375330728, 0.4301597090019468), rPoint) +
        dot(vec2(0.735151469707489, 0.737424373626709), tile)
    );
}

// float valveRed(vec2 point) {
//     float vDither = dot(vec2( 171.0, 231.0 ), point );
//     return fract(vDither / 103.0);  // (103.0, 71. 97.0 )
// }


float shiftedHash12(vec2 point)
{
    point = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(point * point, vec2(3571.0)));
    return fract(ditherShift + (state * state * 7142.0));
}

float shiftedHash13(vec3 point)
{
    point = fract(point * .1031);
    point += dot(point, point.zyx + 31.32);
    return fract(ditherShift + ((point.x + point.y) * point.z));
}

float shiftedRDither(vec2 point) {
    return fract(ditherShift + dot(point, vec2(0.75487766624669276, 0.569840290998)));
}

float shiftedEclecticRDither(vec2 point) {
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.075;

    return fract(dot(point, vec2(0.75487766624669276, 0.569840290998)) + ditherShift + p4);
}

float shiftedDither13(vec2 point)
{
    return fract(ditherShift + dot(point, vec2(0.3076923076923077, 0.5384615384615384)));
}

float shiftedEclecticDither13(vec2 point)
{
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.075;

    return fract(dot(point, vec2(0.3076923076923077, 0.5384615384615384)) + ditherShift + p4);
}

float shiftedDither17(vec2 point) {
    return fract(ditherShift + dot(point, vec2(0.11764705882352941, 0.4117647058823529)));
}

float shiftedEclecticDither17(vec2 point) {
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.15;

    return fract(ditherShift + p4 + dot(point, vec2(0.11764705882352941, 0.4117647058823529)));
}

float shiftedDitherGradNoise(vec2 point) {
    return fract(ditherShift + (52.9829189 * fract(dot(vec2(0.06711056, 0.00583715), point))));
}

float shiftedEclecticDitherGradNoise(vec2 point) {
    vec2 rPoint = 0.0002314814814814815 * point + vec2(0.25, 0.0);
    float state = fract(dot(rPoint * rPoint, vec2(3571.0)));
    float p4 = fract(state * state * 7142.0) * 0.075;

    return fract(52.9829189 * fract(dot(vec2(0.06711056, 0.00583715), point)) + ditherShift + p4);  
}

float shiftedTextureNoise64(vec2 point, sampler2D noise) {
    float dither = texture2DLod(noise, point * 0.015625, 0).r;
    return fract(ditherShift + dither);
}

float shiftedSemiblue(vec2 point) {
    point = point + vec2(frameMod * 5.0, frameMod * 15.0);
    vec2 tile = floor(point * 0.25);
    float flip = mod(tile.x + tile.y, 2.0);
    point = mix(point, point.yx, flip);

    return fract(ditherShift + dot(vec2(0.75487766624669276, 0.569840290998), point) + hash12(tile));
}

float shiftedDitherMakeup(vec2 point) {
    point = point + vec2(frameMod * 9.0, frameMod * 15.0);
    vec2 tile = floor(point * 0.125);
    float flip = mod(tile.x + tile.y, 2.0);
    vec2 zw = mix(point, point.yx, flip);

    return fract(
        ditherShift +
        dot(vec2(0.24512233375330728, 0.4301597090019468), zw) +
        dot(vec2(0.9996657054871321, 0.9998746076598763), tile)
    );
}

// float shiftedValveRed(vec2 point) {
//     float vDither = dot(vec2(171.0, 231.0), point );
//     vDither = fract(vDither / 103.0);  // (103.0, 71. 97.0 )

//     return fract(ditherShift + vDither);
// }


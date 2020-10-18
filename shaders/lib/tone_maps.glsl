/* MakeUp Ultra Fast - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 original_tonemap(vec3 x) {
  return x / pow(vec3_fourth_pow(x) + 1.0, vec3(.25));
}

vec3 custom_lottes_tonemap(vec3 color, float expo) {
	// a = 1.4
	// d = 0.977
	// hdr_max = expo
	// mid_in = .18
	// mid_out = .22

	float pow_a = pow(expo, 1.3678);
	float pow_b = pow(expo, 1.4);

  float b =
      (-0.09065285936842186 + pow_b * .22) /
      ((pow_a - 0.09579916693268369) * .22);
  float c =
      (pow_a * 0.09065285936842186 - pow_b * 0.021075816725190412) /
      ((pow_a - 0.09579916693268369) * .22);

  return pow(color, vec3(1.4)) / (pow(color, vec3(1.3678)) * b + c);
}

vec3 lottes_tonemap(vec3 x, float hdrMax) {
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    float a = 1.6;
    float d = 0.997;
    // const float hdrMax = 8.0;
    float midIn = 0.18;
    float midOut = 0.267;

    // Can be precomputed
    float b =
        (-pow(midIn, a) + pow(hdrMax, a) * midOut) /
        ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
    float c =
        (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) /
        ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);

    return pow(x, vec3(a)) / (pow(x, vec3(a * d)) * b + c);
}

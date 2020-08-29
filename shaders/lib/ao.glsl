float bayer2(vec2 a){
	a = floor(a);
	return fract(dot(a, vec2(.5, a.y * .75)));
}

#define bayer4(a)   (bayer2(.5 * (a)) * .25+ bayer2(a))
// #define bayer8(a)   (bayer4(.5 * (a)) * .25+ bayer2(a))
// #define bayer16(a)  (bayer8(.5 * (a)) * .25+ bayer2(a))
// #define bayer32(a)  (bayer16(.5 * (a)) * .25+ bayer2(a))
// #define bayer64(a)  (bayer32(.5 * (a)) * .25+ bayer2(a))
// #define bayer128(a) (bayer64(.5 * (a)) * 0.25 + bayer2(a))
// #define bayer256(a) (bayer128(.5 * (a)) * 0.25 + bayer2(a))

float ld(float depth) {
	return (2.0 * near) / (far + near - depth * (far - near));
}

vec2 offsetDist(float x, int s){
	float n = fract(x * 1.414) * 3.1416;
	return vec2(cos(n), sin(n)) * x / s;
}

float dbao(sampler2D depth, float dither){
	float ao = 0.0;

	int samples = AOSTEPS;

	float d = texture2D(depth, texcoord.xy).r;
	float hand = float(d < 0.56);
	d = ld(d);

	float sd = 0.0;
	float angle = 0.0;
	float dist = 0.0;
	vec2 scale = 1.5 * vec2(1.0 / aspectRatio, 1.0) * gbufferProjection[1][1] / (2.74747742 * max(far * d, 6.0));

	for (int i = 1; i <= samples; i++) {
		vec2 offset = offsetDist(i + dither, samples) * scale;

		sd = ld(texture2D(depth, texcoord.xy + offset).r);
		float sample = far * (d - sd) * 2.0;
		if (hand > 0.5) sample *= 1024.0;
		angle = clamp(0.5 - sample, 0.0, 1.0);
		dist = clamp(0.25 * sample - 1.0, 0.0 ,1.0);

		sd = ld(texture2D(depth, texcoord.xy - offset).r);
		sample = far * (d - sd) * 2.0;
		if (hand > 0.5) sample *= 1024.0;
		angle += clamp(0.5 - sample,0.0 ,1.0);
		dist += clamp(0.25 * sample - 1.0,0.0 ,1.0);

		ao += clamp(angle + dist, 0.0, 1.0);
	}
	ao /= samples;

	return pow(ao, .45);
}

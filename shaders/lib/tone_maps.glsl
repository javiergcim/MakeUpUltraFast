#define WHITE_CURVE 4.0 // [1.0 1.5 2.0 2.5 3.0 3.5 4.0]
#define LOWER_CURVE 1.2 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define UPPER_CURVE 0.8 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

vec3 BSL_like(vec3 x){
	x = x / pow(pow(x, vec3(WHITE_CURVE)) + 1.0, vec3(1.0 / WHITE_CURVE));
	x = pow(x,mix(vec3(LOWER_CURVE),vec3(UPPER_CURVE),sqrt(x)));
	return x;
}

vec3 uncharted2Tonemap(vec3 x) {
  float A = 0.15;
  float B = 0.50;
  float C = 0.10;
  float D = 0.20;
  float E = 0.02;
  float F = 0.30;
  float W = 11.2;
  return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

vec3 uncharted2(vec3 color) {
  const float W = 11.2;
  float exposureBias = 4.0;  // 2.0
  vec3 curr = uncharted2Tonemap(exposureBias * color);
  vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
  return curr * whiteScale;
}

vec3 tonemapFilmic(vec3 x) {
  vec3 X = max(vec3(0.0), x - 0.004);
  vec3 result = (X * (6.2 * X + 0.5)) / (X * (6.2 * X + 1.7) + 0.06);
  return pow(result, vec3(2.2));
}

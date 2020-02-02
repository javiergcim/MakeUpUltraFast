float interpolateSmooth1(float x) {
  return x * x * (3.0 - 2.0 * x);
}

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

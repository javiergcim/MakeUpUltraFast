#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

vec3 to_screen_space(vec3 p) {
  vec4 iProjDiag =
		vec4(
			gbufferProjectionInverse[0].x,
			gbufferProjectionInverse[1].y,
			gbufferProjectionInverse[2].zw
		);
  vec3 p3 = p * 2.0 - 1.0;
  vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
  return fragposition.xyz / fragposition.w;
}

vec3 toClipSpace3Prev(vec3 viewSpacePosition) {
    return projMAD(gbufferPreviousProjection, viewSpacePosition) / -viewSpacePosition.z * 0.5 + 0.5;
}

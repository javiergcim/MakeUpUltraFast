#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

vec3 to_screen_space(vec3 p) {
  vec4 i_proj_diag =
		vec4(
			gbufferProjectionInverse[0].x,
			gbufferProjectionInverse[1].y,
			gbufferProjectionInverse[2].zw
		);
  vec3 p3 = p * 2.0 - 1.0;
  vec4 fragposition = i_proj_diag * p3.xyzz + gbufferProjectionInverse[3];
  return fragposition.xyz / fragposition.w;
}

vec3 to_clip_space(vec3 view_space_pos) {
    return projMAD(gbufferPreviousProjection, view_space_pos) / -view_space_pos.z * 0.5 + 0.5;
}

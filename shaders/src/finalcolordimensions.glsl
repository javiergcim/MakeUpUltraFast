// block_color.rgb =
//   mix(
//     block_color.rgb,
//     gl_Fog.color.rgb * .5,
//     ld(d)
//   );

block_color.rgb = vec3(ld(d));
